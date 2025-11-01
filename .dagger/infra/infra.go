package infra

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/url"
	"strings"

	"github.com/google/go-containerregistry/pkg/authn"
)

type dockerConfig struct {
	Auths map[string]struct {
		Auth string `json:"auth"` // base64("user:pass") or token
	} `json:"auths"`
}

// KeychainFromDockerCfgBase64 builds an authn.Keychain from a base64-encoded Docker config.json
// that uses inline auths (no credStore/credHelpers). Supports Docker Hub aliases.
func KeychainFromDockerCfgBase64(b64 string) (authn.Keychain, error) {
	if strings.TrimSpace(b64) == "" {
		return nil, fmt.Errorf("empty docker config")
	}

	cfgBytes, err := base64.StdEncoding.DecodeString(b64)
	if err != nil {
		return nil, fmt.Errorf("decode base64 docker config: %w", err)
	}

	var cfg dockerConfig
	if err := json.Unmarshal(cfgBytes, &cfg); err != nil {
		return nil, fmt.Errorf("unmarshal docker config: %w", err)
	}
	if len(cfg.Auths) == 0 {
		return nil, fmt.Errorf("docker config has no inline auths (credStore/credHelpers unsupported)")
	}

	authMap := make(map[string]authn.Authenticator)
	for k, v := range cfg.Auths {
		host := normHost(k)
		if host == "" || v.Auth == "" {
			continue
		}
		user, pass := decodeAuthField(v.Auth)

		// Map Docker Hub aliases
		if isHub(host) {
			b := &authn.Basic{Username: user, Password: pass}
			authMap["index.docker.io"] = b
			authMap["registry-1.docker.io"] = b
			authMap["docker.io"] = b
			continue
		}
		authMap[host] = &authn.Basic{Username: user, Password: pass}
	}

	if len(authMap) == 0 {
		return nil, fmt.Errorf("no usable auth entries found in docker config")
	}

	return &inMemKeychain{byHost: authMap}, nil
}

// ---- helpers ----

type inMemKeychain struct {
	byHost map[string]authn.Authenticator
}

func (k *inMemKeychain) Resolve(r authn.Resource) (authn.Authenticator, error) {
	host := r.RegistryStr()
	if a, ok := k.byHost[host]; ok {
		return a, nil
	}
	// Fallback for Docker Hub aliases
	if isHub(host) {
		if a, ok := k.byHost["index.docker.io"]; ok {
			return a, nil
		}
		if a, ok := k.byHost["registry-1.docker.io"]; ok {
			return a, nil
		}
		if a, ok := k.byHost["docker.io"]; ok {
			return a, nil
		}
	}
	return authn.Anonymous, nil
}

func isHub(h string) bool {
	switch h {
	case "docker.io", "registry-1.docker.io", "index.docker.io":
		return true
	default:
		return false
	}
}

// Accepts keys like "https://cr.nrtn.dev", "cr.nrtn.dev", "https://index.docker.io/v1/"
func normHost(key string) string {
	k := strings.TrimSpace(key)
	if strings.HasPrefix(k, "http://") || strings.HasPrefix(k, "https://") {
		if u, err := url.Parse(k); err == nil && u.Host != "" {
			k = u.Host
		}
	}
	k = strings.TrimSuffix(k, "/")
	k = strings.TrimSuffix(k, "/v1")
	k = strings.TrimSuffix(k, "/v1/")
	// If path remains, keep host part only
	if i := strings.IndexByte(k, '/'); i > 0 {
		k = k[:i]
	}
	return k
}

// decode base64("user:pass") -> (user, pass). If only token provided, treat as password.
func decodeAuthField(b64 string) (string, string) {
	raw, err := base64.StdEncoding.DecodeString(b64)
	if err != nil {
		return "", ""
	}
	parts := strings.SplitN(string(raw), ":", 2)
	if len(parts) == 2 {
		return parts[0], parts[1]
	}
	return "token", string(raw)
}

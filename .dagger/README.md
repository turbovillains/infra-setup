# Infra Setup - Dagger Module

Dagger module for importing container images to private registries with multiarch support.

## What This Does

Imports 215+ container images from various public registries (Docker Hub, Quay, GCR, etc.) to a private registry while preserving multiarch manifests (arm64, amd64, etc.). Uses `crane copy` for true multiarch support instead of single-platform image pulls.

## Quick Start

```bash
# List all available images with version substitution
dagger call list-images

# List images matching a pattern
dagger call list-images --pattern="golang"

# Import specific images by pattern
dagger call import-image --pattern="postgres"

# Import all 215+ images
dagger call import-images
```

## How It Works

### Module Source vs Constructor Source

Dagger has two concepts of "source":

1. **Module Source** (`dag.CurrentModule().Source()`)
   - From `dagger.json` `"source": ".dagger"`
   - Contains only module code (`.dagger/` folder)
   - Isolated sandbox for module code

2. **Constructor Source** (`m.Source` from `New()`)
   - From `New()` with `+defaultPath="."`
   - The repo root where you run `dagger`
   - Where `variables.yml` lives
   - **Lazy evaluation**: Only files you reference (like `variables.yml`) get copied

### The Constructor Pattern

```go
func New(
    // +defaultPath="."
    // +ignore=["gitlab", ".git"]
    source *dagger.Directory,
    // +optional
    // +default="variables.yml"
    variablesFile string,
    // +optional
    // +default="cr.nrtn.dev"
    targetRegistry string,
) *InfraSetup
```

- `+defaultPath="."` = Repo root becomes the source
- `+ignore=["gitlab", ".git"]` = Exclude unnecessary directories
- `+default` annotations = Optional parameters with defaults
- **Lazy evaluation** = Only `variables.yml` is copied when accessed via `m.Source.File(m.VariablesFile)`

## Configuration

### Variables File

Default: `variables.yml` in repo root

Override:
```bash
dagger call --variables-file="other-vars.yml" list-images
```

### Target Registry

Default: `cr.nrtn.dev`

Override:
```bash
dagger call --target-registry="my-registry.io" import-images
```

## Functions

### test-paths

Debug function showing what's visible to the module:

```bash
dagger call test-paths
```

Shows:
- Module source contents (`.dagger/` folder)
- Constructor source contents (repo root)
- Whether `variables.yml` is accessible

### list-variables

Show all variables from `variables.yml`:

```bash
dagger call list-variables
```

### list-images

Dry-run showing what would be imported:

```bash
# All images
dagger call list-images

# Filter by pattern
dagger call list-images --pattern="golang"
dagger call list-images --pattern="postgres"
dagger call list-images --pattern="kubernetes"
```

### import-image

Import images matching a pattern:

```bash
# Import all golang images
dagger call import-image --pattern="golang"

# Import to custom registry
dagger call --target-registry="my-registry.io" \
  import-image --pattern="postgres"
```

### import-images

Import all 215+ images:

```bash
# Default registry (cr.nrtn.dev)
dagger call import-images

# Custom registry
dagger call --target-registry="registry.example.com" import-images
```

## GitLab CI Integration

In GitLab pipelines, use environment variables for configuration:

```yaml
import-images:
  stage: import
  script:
    - |
      dagger call \
        --target-registry="${DOCKER_HUB:-cr.nrtn.dev}" \
        import-images
```

**Note**: `DOCKER_HUB` is used for historical reasons - it contains the target private registry URL, not Docker Hub itself.

## Variable Expansion

Variables from `variables.yml` are expanded in image references:

```yaml
# variables.yml
variables:
  GOLANG_VERSION: "1.25.3-trixie"
  GOLANG_ALPINE_VERSION: "1.25.3-alpine"
```

```go
// Image list (dense bash-style format)
"golang:${GOLANG_VERSION}:::prepend_name=library/"
"golang:${GOLANG_ALPINE_VERSION}:::prepend_name=library/"
```

**Important**: No default values like bash's `${VAR:-default}`. If a variable is undefined, the import fails with an error.

## Image Options

Images support options via `:::option=value` syntax:

```go
"debian:${DEBIAN_VERSION}:::prepend_name=library/"
```

**prepend_name**: Adds a prefix to the destination image name
- Source: `debian:trixie-20251020-slim`
- Destination: `cr.nrtn.dev/library/debian:trixie-20251020-slim`

## Multiarch Support

Uses `crane copy` to preserve multiarch manifests:

```go
func (m *InfraSetup) pullAndPush(ctx context.Context, source, destination string) error {
    // Use crane copy to preserve multiarch manifests
    _, err := dag.Container().
        From("gcr.io/go-containerregistry/crane:latest").
        WithExec([]string{"copy", source, destination}).
        Sync(ctx)
    return err
}
```

This ensures all architectures (amd64, arm64, etc.) are copied, not just the runner's architecture.

## Image Destination Logic

The `buildDestination` function handles different image formats:

1. **No prefix** (e.g., `debian:tag`)
   → `cr.nrtn.dev/library/debian:tag`

2. **Registry prefix** (e.g., `quay.io/minio/minio:tag`)
   → `cr.nrtn.dev/minio/minio:tag`

3. **Org prefix** (e.g., `gitlab/gitlab-ce:tag`)
   → `cr.nrtn.dev/gitlab/gitlab-ce:tag`

Prepend name is applied before the image name in all cases.

## 215+ Images Included

Categories:
- **Base images**: debian, ubuntu, alpine, busybox
- **Languages**: golang, python, node, java
- **Databases**: postgres, mongodb, redis, mysql, clickhouse, scylladb
- **Messaging**: kafka, rabbitmq, nats
- **K8s ecosystem**: ingress-nginx, cert-manager, calico, metallb
- **Observability**: prometheus, grafana, elasticsearch, loki
- **GitLab**: gitlab-ce, gitlab-runner, gitlab-agent
- **GPU**: NVIDIA GPU Operator and components
- **And many more...**

See `getImageEntries()` in `main.go` for the complete list.

## Development

Test the module locally:

```bash
# Run from repo root
cd /path/to/infra-setup

# Test path resolution
dagger call test-paths

# List images with pattern
dagger call list-images --pattern="golang"
```

## Troubleshooting

### "variable not defined" error

Variables must exist in `variables.yml`. No bash-style defaults are supported.

Fix: Add the missing variable to `variables.yml`

### "No images matched pattern"

The pattern uses simple string matching (`strings.Contains`).

Try a broader pattern:
```bash
# Too specific
dagger call list-images --pattern="golang:1.25"

# Better
dagger call list-images --pattern="golang"
```

### Registry authentication

**Important**: Crane runs inside a Dagger container and doesn't automatically have access to your Docker credentials.

For now, crane will attempt to use anonymous access (works for public registries). For private registries, you'll need to either:

1. Set up registry authentication in GitLab CI with secrets
2. Use `DOCKER_CONFIG` environment variable
3. Mount Docker credentials into the container

Example for GitLab CI:
```yaml
import-images:
  variables:
    DOCKER_CONFIG_JSON: ${DOCKER_AUTH_CONFIG}  # GitLab CI secret
  script:
    - dagger call import-images
```

**Note**: This is a known limitation. Future versions may use Dagger's `WithRegistryAuth` for better credential handling.

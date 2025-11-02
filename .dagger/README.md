# Infra Setup - Dagger Module

Dagger module for importing and archiving container images with multiarch support.

## What This Does

- **Import**: Copies 215+ container images from public registries (Docker Hub, Quay, GCR, etc.) to a private registry while preserving multiarch manifests (arm64, amd64, etc.)
- **Archive**: Creates compressed OCI tarballs of imported images for backup/airgap deployments
- **Multiarch**: Uses `crane` with OCI format for true multiarch support (all architectures preserved)

## Quick Start

```bash
# List all available images with version substitution
dagger call list-images

# List images matching a pattern
dagger call list-images --pattern="golang"

# Import specific images by pattern
dagger call \
  with-docker-cfg --docker-cfg env://DOCKER_CFG \
  import-images --pattern="postgres"

# Import all 215+ images
dagger call \
  with-docker-cfg --docker-cfg env://DOCKER_CFG \
  import-images

# Archive images to local directory (multiarch)
dagger call \
  with-docker-cfg --docker-cfg env://DOCKER_CFG \
  archive-images-for-export --pattern="alpine" \
  export --path=./archives

# Archive and upload to storage
dagger call \
  with-docker-cfg --docker-cfg env://DOCKER_CFG \
  with-ssh-private-key --ssh-private-key env://SSH_PRIVATE_KEY \
  archive-images-to-storage --infra-bucket="v1.0.0" --pattern="alpine"
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

### archive-images-for-export

Create compressed OCI tarballs of images and export to local filesystem. Images are pulled from the target registry (must be imported first).

```bash
# Archive all alpine images (multiarch by default)
dagger call \
  with-docker-cfg --docker-cfg env://DOCKER_CFG \
  archive-images-for-export --pattern="alpine" \
  export --path=./archive

# Archive specific platform
dagger call \
  with-docker-cfg --docker-cfg env://DOCKER_CFG \
  archive-images-for-export --pattern="postgres" --platform="linux/arm64" \
  export --path=./archive

# Archive all images as multiarch
dagger call \
  with-docker-cfg --docker-cfg env://DOCKER_CFG \
  archive-images-for-export \
  export --path=./archive
```

**Key features:**
- Uses OCI format (`--format oci`) for proper multiarch support
- Default platform: `all` (multiarch - includes amd64, arm64, etc.)
- Compressed with zstd (`-T0` uses all CPU cores)
- Filenames: `{registry}-{image}-{tag}-multiarch.tar.zst` or `{registry}-{image}-{tag}-{platform}.tar.zst`
- Returns Dagger Directory - chain `.export()` to save to host

### archive-images-to-storage

Create compressed OCI tarballs and upload directly to remote storage via rsync. No local export needed.

```bash
# Archive and upload alpine images to storage
dagger call \
  with-docker-cfg --docker-cfg env://DOCKER_CFG \
  with-ssh-private-key --ssh-private-key env://SSH_PRIVATE_KEY \
  archive-images-to-storage \
    --infra-bucket="v1.0.0" \
    --pattern="alpine"

# Archive all images to storage bucket
dagger call \
  with-docker-cfg --docker-cfg env://DOCKER_CFG \
  with-ssh-private-key --ssh-private-key env://SSH_PRIVATE_KEY \
  archive-images-to-storage --infra-bucket="production-2024"
```

**Upload destination:** `oleksii@tank.noroutine.me:/ifs/attic/infra/{infra-bucket}/images/`

**Key features:**
- Same OCI multiarch format as `archive-images-for-export`
- Uploads directly via rsync (no local storage needed)
- Uses SSH key for authentication (base64-encoded secret)
- Returns summary string instead of Directory

## Forgejo/GitLab CI Integration

### Secrets Setup

Both `DOCKER_CFG` and `SSH_PRIVATE_KEY` must be stored as **base64-encoded** secrets:

```bash
# Prepare DOCKER_CFG (base64-encode your Docker config)
cat ~/.docker/config.json | base64 -w0

# Prepare SSH_PRIVATE_KEY (base64-encode your SSH private key)
cat ~/.ssh/id_rsa | base64 -w0
```

Add these to your Forgejo/GitLab secrets:
- `DOCKER_CFG` - Base64-encoded Docker config for registry authentication
- `SSH_PRIVATE_KEY` - Base64-encoded SSH private key for storage uploads
- `DAGGER_CLOUD_TOKEN` - Dagger Cloud token (optional, for caching)

### Workflow Examples

**Import images:**
```yaml
import-images:
  stage: import
  script:
    - |
      dagger call \
        with-docker-cfg --docker-cfg env://DOCKER_CFG \
        import-images
  env:
    DOCKER_CFG: ${{ secrets.DOCKER_CFG }}
```

**Archive to storage (Forgejo):**
```yaml
archive-images:
  needs: import-images
  steps:
    - name: Install Dagger
      uses: https://github.com/dagger/dagger-for-github@v8.2.0
      with:
        version: "latest"

    - name: Archive images to storage
      run: |
        dagger call \
          with-docker-cfg --docker-cfg env://DOCKER_CFG \
          with-ssh-private-key --ssh-private-key env://SSH_PRIVATE_KEY \
          archive-images-to-storage \
            --infra-bucket="${{ steps.version.outputs.infra_version }}" \
            --pattern="alpine"
      env:
        DOCKER_CFG: ${{ secrets.DOCKER_CFG }}
        SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
        DAGGER_CLOUD_TOKEN: ${{ secrets.DAGGER_CLOUD_TOKEN }}
```

**Using SSH key in workflows:**

When using the SSH key outside of Dagger (e.g., for git operations), decode it first:

```yaml
- name: Set up SSH
  run: |
    eval "$(ssh-agent -s)"
    echo '${{ secrets.SSH_PRIVATE_KEY }}' | base64 -d | ssh-add -
```

**Note**: `DOCKER_HUB` is used for historical reasons in some places - it contains the target private registry URL, not Docker Hub itself.

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

### Registry Authentication

Registry authentication is handled via base64-encoded `DOCKER_CFG` secret:

```bash
# Encode your Docker config
cat ~/.docker/config.json | base64 -w0
```

The module decodes this secret and uses it with crane for multiarch image operations:

```go
// Internal implementation
container = container.
    WithMountedSecret("/tmp/docker-config-b64", m.DockerCfg).
    WithExec([]string{"sh", "-c",
        "mkdir -p /root/.docker && base64 -d /tmp/docker-config-b64 > /root/.docker/config.json"})
```

**Authentication flow:**
1. `WithDockerCfg()` stores the base64-encoded secret
2. Secret is mounted to temp location in container
3. Decoded to `/root/.docker/config.json`
4. Crane uses standard Docker config for authentication
5. Supports all registries in your Docker config (Docker Hub, private registries, etc.)

### Storage Upload Authentication

Storage uploads use base64-encoded SSH private key:

```bash
# Encode your SSH key
cat ~/.ssh/id_rsa | base64 -w0
```

The key is decoded and used for rsync operations:

```go
// Internal implementation
container = container.
    WithMountedSecret("/tmp/ssh-key-b64", m.SshPrivateKey).
    WithExec([]string{"sh", "-c",
        "mkdir -p /root/.ssh && base64 -d /tmp/ssh-key-b64 > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa"})
```

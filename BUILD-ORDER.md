# Build Order for Infrastructure Images

This document describes the build system for infrastructure images.

## Build System Overview

The build system uses a single unified script `./build.sh` that automatically discovers stages from `docker-compose.*.yml` files. The script is designed to be simple and non-opinionated about build order or stage dependencies.

### Current Stages

Stages are automatically discovered from compose files. Current stages:

- **scratch** (`docker-compose.scratch.yml`) - Base components like CA certificates and tools
- **custom** (`docker-compose.custom.yml`) - Application images

To see available stages and components:

```bash
./build.sh --help
./build.sh <stage> --list
```

### Adding New Stages

Simply create a new `docker-compose.newstage.yml` file and the build system will automatically pick it up. No code changes needed.

## Build Script Usage

```bash
./build.sh [stage] [options]

Options:
  --registry REGISTRY      Container registry (default: cr.noroutine.me)
  --namespace NAMESPACE    Image namespace (default: infra-dev)
  --version VERSION        Image version tag (default: git SHA or 'dev')
  --push                   Push images after build
  --components COMP1,COMP2 Build only specific components
  --list                   List available components for the stage
```

## Basic Build Examples

```bash
# Build scratch stage locally
./build.sh scratch

# Build and push scratch stage
./build.sh scratch --push

# Build custom stage with specific version
./build.sh custom --version v1.0.0 --push

# Build only specific components
./build.sh custom --components argocd,grafana --push

# List components in a stage
./build.sh scratch --list
./build.sh custom --list

# Use custom registry
./build.sh scratch --registry docker.io --namespace myorg --push
```

## Build Dependencies

**The build script does NOT enforce or track stage dependencies.** You are responsible for building stages in the correct order and pushing images before building dependent stages.

Generally, if one stage's images use another stage's images as base images, build and push the base stage first:

```bash
# Example: If custom depends on scratch
./build.sh scratch --push
./build.sh custom --push
```

## CI/CD

The Forgejo workflows use the same `./build.sh` script for consistency.

### images.yml (automatic - runs on push to master)
**Trigger**:
- Automatic on push to master
- Automatic on pull requests (for testing)
- Manual via workflow_dispatch

**Jobs run in sequence**:
1. **import-images** - Imports base images from upstream registries
2. **archive-images** - Archives images to storage (tags only)
3. **build-images** - Builds all stages using `./build.sh`

**Features**:
- Uses `./build.sh` for all builds
- Pushes to `infra-dev` namespace for commits, `infra` for tags
- Uses `cr.noroutine.me` as default registry (override with `IMAGE_REGISTRY` variable)
- Uses existing `DOCKER_CFG` secret for authentication

### mirror.yml (manual only)
**Trigger**: Manual only via workflow_dispatch

**What it does**:
- Mirrors repository to GitHub (turbovillains/infra-setup)
- Pushes to GitLab (git.nrtn.dev/infra/infra-setup) to trigger CI/CD
- Requires `SSH_PRIVATE_KEY` secret

## Variables

Build variables are loaded from `variables.yml` automatically by `./build.sh`.

Key environment variables (can be overridden):
- `IMAGE_REGISTRY` - Container registry (default: cr.noroutine.me)
- `INFRA_NAMESPACE` - Image namespace (default: infra-dev)
- `INFRA_VERSION` - Version tag (default: git SHA or 'dev')
- `PUSH` - Set to 'true' to push images (default: false)

## Container Registry

The default registry is `cr.noroutine.me`. This can be overridden via:
- `--registry` flag
- `IMAGE_REGISTRY` environment variable

### Required Secrets (for CI/CD)

For Forgejo Actions workflows:
- `DOCKER_CFG` - Base64 encoded Docker config.json (authentication)
- `SSH_PRIVATE_KEY` - SSH key for mirroring (mirror.yml only)

Optionally set:
- `IMAGE_REGISTRY` - Override default registry

```bash
# Create DOCKER_CFG secret:
cat ~/.docker/config.json | base64
```

## Local Development

### Prerequisites

**Required:** `yq` must be installed to load variables from `variables.yml`:

```bash
# macOS
brew install yq

# Linux
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
chmod +x /usr/local/bin/yq

# Or see: https://github.com/mikefarah/yq
```

### Local Build Examples

```bash
# Build locally without pushing
./build.sh scratch
./build.sh custom

# Build with custom version
./build.sh scratch --version test --namespace infra-dev

# Build and push to cr.noroutine.me
docker login cr.noroutine.me
./build.sh scratch --push
./build.sh custom --push

# Build and push to Docker Hub
docker login docker.io
./build.sh scratch --registry docker.io --namespace myorg --push
./build.sh custom --registry docker.io --namespace myorg --push

# Build specific components only
./build.sh custom --components argocd,grafana
```

### Quick Development Workflow

```bash
# 1. Make changes to Dockerfiles
# 2. Build locally to test
./build.sh <stage>

# 3. If good, push
./build.sh <stage> --push
```

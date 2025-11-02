# Build Order for Infrastructure Images

This document describes the build stages and their dependencies for the infrastructure images.

## Build Stages

### Stage 1: Scratch
**Script:** `./build-scratch.sh`
**Compose:** `docker-compose.scratch.yml`
**Dependencies:** None

Components:
- `noroutine-ca` - Custom CA certificates bundle

```bash
# Build and push scratch stage (uses cr.nrtn.dev by default)
./build-scratch.sh --namespace infra --version v1.0.0 --push

# Or with custom registry
./build-scratch.sh --registry docker.io --namespace infra --version v1.0.0 --push
```

### Stage 2: Base
**Script:** `./build-base.sh`
**Compose:** `docker-compose.base.yml`
**Dependencies:** Scratch stage (noroutine-ca)

Components:
- `tools` - Debian-based tools image with custom CA
- `debian` - Debian base image with custom CA
- `ubuntu24` - Ubuntu 24.04 base image with custom CA
- `alpine` - Alpine base image with custom CA
- `noroutine-buoy` - Custom Alpine-based image
- `busybox` - Busybox image with custom CA
- `jdk-zulu` - Azul Zulu OpenJDK with custom CA
- `jdk-temurin` - Eclipse Temurin JDK with custom CA
- `golang` - Go language image with custom CA
- `python` - Python image with custom CA
- `python-slim` - Python slim image with custom CA

```bash
# Build and push base stage (uses cr.nrtn.dev by default)
./build-base.sh --namespace infra --version v1.0.0 --push

# Or with custom registry
./build-base.sh --registry docker.io --namespace infra --version v1.0.0 --push
```

### Stage 3: Build
**Script:** `./build-build.sh` (TODO)
**Compose:** `docker-compose.build.yml` (TODO)
**Dependencies:** Base stage images

Components: Various application images that depend on base images.

### Stage 4: Build2
**Script:** `./build-build2.sh` (TODO)
**Compose:** `docker-compose.build2.yml` (TODO)
**Dependencies:** Build stage images

Components: Final-stage images that depend on build stage images.

## Complete Build Sequence

To build all stages in order (using default registry cr.nrtn.dev):

```bash
# Stage 1: Scratch
./build-scratch.sh --push

# Stage 2: Base (requires scratch pushed)
./build-base.sh --push

# Stage 3: Build (requires base pushed)
# TODO: ./build-build.sh --push

# Stage 4: Build2 (requires build pushed)
# TODO: ./build-build2.sh --push
```

To use a different registry:

```bash
./build-scratch.sh --registry docker.io --push
./build-base.sh --registry docker.io --push
```

## CI/CD

The Forgejo workflows:

### images.yml (automatic - runs on push to master)
**Trigger**:
- Automatic on push to master
- Automatic on pull requests (for testing)
- Manual via workflow_dispatch

**Jobs run in sequence**:
1. **import-images** - Imports base images from upstream registries, generates artifacts
2. **archive-images** - Archives images to storage (tags only, runs in parallel with build)
3. **build-images** - Builds scratch and base stages (runs after import-images completes)

**Build stages in build-images job**:
- Scratch stage: noroutine-ca
- Base stage: tools, debian, ubuntu24, alpine, noroutine-buoy, busybox, jdk-zulu, jdk-temurin, golang, python, python-slim, node

**Features**:
- Uses `needs:` to enforce job dependencies
- Pushes to `infra-dev` namespace for commits, `infra` for tags
- Uses `cr.nrtn.dev` as default registry (override with `IMAGE_REGISTRY` variable)
- Generates build summaries dynamically from docker-compose files
- Uses existing `DOCKER_CFG` secret for authentication
- Single checkout per job (efficient)

### mirror.yml (manual only)
**Trigger**: Manual only via workflow_dispatch

**What it does**:
- Mirrors repository to GitHub (turbovillains/infra-setup)
- Pushes to GitLab (git.nrtn.dev/infra/infra-setup) to trigger CI/CD
- Uses full git history (fetch-depth: 0)
- Requires `SSH_PRIVATE_KEY` secret

**When to use**: Run manually when you want to sync the repository to external mirrors (GitHub and GitLab).

## Variables

All build variables are loaded from `variables.yml` for stages that need them (base and later).

Required environment variables:
- `IMAGE_REGISTRY` - Container registry (default: cr.nrtn.dev)
- `INFRA_NAMESPACE` - Image namespace (default: infra-dev for commits, infra for tags)
- `INFRA_VERSION` - Version tag (default: dev, or short commit SHA, or tag name)

## Container Registry

The default registry is `cr.nrtn.dev`. In CI/CD workflows, this can be overridden using the `IMAGE_REGISTRY` variable in Forgejo Actions.

### Required Secrets

For Forgejo Actions workflows, set these secrets:
- `DOCKER_CFG` - Base64 encoded Docker config.json (contains authentication for all registries)

Optionally, set these repository variables:
- `IMAGE_REGISTRY` - Override the default registry (cr.nrtn.dev)

The `DOCKER_CFG` secret should be a base64-encoded version of your `~/.docker/config.json` file:
```bash
cat ~/.docker/config.json | base64
```

This secret is shared with the `import-images` workflow, so no additional authentication configuration is needed.

## Generic Component Builds

The `docker/generic/` folder is used for components that just retag existing images from one registry to another. These are components like `node` in the GitLab pipeline that pull `library/node` and retag to the infrastructure registry. This semantic is maintained for compatibility with the existing GitLab pipeline.

## Local Development

### Prerequisites

For local builds, you **must** have `yq` installed to load variables from `variables.yml`:

```bash
# macOS
brew install yq

# Linux
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
chmod +x /usr/local/bin/yq

# Or see: https://github.com/mikefarah/yq
```

The build scripts will fail with an error if `yq` is not found, as the variables are required for docker-compose to work correctly.

### Build locally without pushing:

```bash
# Stage 1
./build-scratch.sh --namespace infra-dev --version test

# Stage 2
./build-base.sh --namespace infra-dev --version test
```

To test with push (to cr.nrtn.dev):

```bash
docker login cr.nrtn.dev
./build-scratch.sh --namespace infra-dev --version test --push
./build-base.sh --namespace infra-dev --version test --push
```

Or to push to Docker Hub:

```bash
docker login docker.io
./build-scratch.sh --registry docker.io --namespace infra-dev --version test --push
./build-base.sh --registry docker.io --namespace infra-dev --version test --push
```

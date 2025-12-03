# Infrastructure Setup CLI

Simple Python CLI for managing container image imports and generating dependency tracking artifacts.

## Features

- 🚀 **Import images** using regsync
- 📋 **List images** with beautiful tables
- 📦 **Generate artifacts** (Dockerfile + infra.json) for Dependabot

## Installation

```bash
# Using uv (recommended)
uv sync

# Or install in development mode
pip install -e .
```

## Usage

### Import Images

Import images to your target registry using regsync:

```bash
uv run infra import-images --registry cr.noroutine.me
```

Options:
- `--config, -c`: Path to regsync.yml (default: regsync.yml)
- `--variables, -v`: Path to variables.yml (default: variables.yml)
- `--registry, -r`: Target registry (default: cr.noroutine.me)
- `--verbosity`: Regsync verbosity level (default: info)

### List Images

List all images that would be imported:

```bash
uv run infra list-images
```

Filter by pattern:

```bash
uv run infra list-images --pattern postgres
```

Options:
- `--config, -c`: Path to regsync.yml (default: regsync.yml)
- `--variables, -v`: Path to variables.yml (default: variables.yml)
- `--registry, -r`: Target registry (default: cr.noroutine.me)
- `--pattern, -p`: Filter images by pattern

### Generate Artifacts

Generate Dockerfile and infra.json for dependency tracking:

```bash
uv run infra generate-artifacts --output ./artifacts --version 1.0.0
```

This creates:
- `artifacts/Dockerfile` - Multi-stage Dockerfile with all upstream images
- `artifacts/infra.json` - JSON metadata with version and image list

Options:
- `--output, -o`: Output directory (default: ./artifacts)
- `--config, -c`: Path to regsync.yml (default: regsync.yml)
- `--variables, -v`: Path to variables.yml (default: variables.yml)
- `--registry, -r`: Target registry (default: cr.noroutine.me)
- `--version`: Infrastructure version (default: dev)

## Architecture

### Single Source of Truth: regsync.yml

The `regsync.yml` configuration file is the **single source of truth** for all image definitions. The CLI:

1. Parses `regsync.yml` with Go template syntax (`{{ env "VAR" }}`)
2. Loads variables from `variables.yml`
3. Expands templates to get final image names
4. Performs operations on the expanded list

This eliminates duplication and ensures consistency across all tools.

### No Dagger Overhead

Unlike the previous Dagger-based approach, this CLI:
- ✅ Runs directly on the host (no container overhead)
- ✅ Simple Python code (easy to read and modify)
- ✅ Fast startup (no GraphQL/API layer)
- ✅ Works great in CI (clean, colored output)

## CI/CD Integration

The workflow uses this CLI:

```yaml
- name: Install uv
  uses: astral-sh/setup-uv@v5

- name: Import images
  run: uv run infra import-images --registry ${{ env.IMAGE_REGISTRY }}

- name: Generate artifacts
  run: uv run infra generate-artifacts --output ./artifacts --version ${{ steps.version.outputs.infra_version }}
```

## Dependencies

- **pyyaml**: Parse YAML configuration files
- **rich**: Beautiful terminal output with tables and colors
- **typer**: Modern CLI framework with automatic help generation

## Development

```bash
# Install in development mode
uv sync

# Run commands
uv run infra --help
uv run infra list-images
uv run infra generate-artifacts --output /tmp/artifacts

# Run tests (when added)
uv run pytest
```

# Regsync Configuration Usage

This directory contains a regsync configuration generated from the Dagger `getImageEntries()` function.

## Files

- `regsync.yml` - Main regsync configuration with 223 image sync entries
- `export-vars.sh` - Helper script to export variables from `variables.yml`
- `variables.yml` - Version variables for all images

## Quick Start

### 1. Export Environment Variables

You need to export the variables from `variables.yml` as environment variables:

```bash
# Using the helper script (requires yq)
source export-vars.sh

# Or manually export specific variables
export TARGET_REGISTRY=cr.noroutine.me
export DEBIAN_VERSION=trixie-20251117-slim
export UBUNTU_NOBLE_VERSION=noble-20251013
# ... etc
```

### 2. Run Regsync

```bash
# Sync all images
regsync once -c regsync.yml

# Dry run to see what would be synced
regsync once -c regsync.yml --dry-run

# Sync specific images (if regsync supports filtering)
# Check regsync documentation for filter options
```

## Configuration Details

- **Source images**: Pulled from public registries (Docker Hub, Quay.io, ghcr.io, etc.)
- **Target registry**: `{{ env "TARGET_REGISTRY" }}` (defaults to `cr.noroutine.me` via export-vars.sh)
- **Image count**: 223 images total
- **Prepend logic**: Library images (like `debian`, `alpine`) are prefixed with `library/` in the target

## Comparison with Dagger

This regsync config mirrors the behavior of:
```bash
dagger call import-images
```

But uses regsync's native synchronization instead of the Dagger/crane-based approach.

## Environment Variables

All version variables from `variables.yml` must be exported. The export-vars.sh script handles this automatically.

Required variables include:
- `TARGET_REGISTRY` - Target registry hostname
- All version variables (`DEBIAN_VERSION`, `ALPINE_VERSION`, etc.)

## Notes

- The configuration uses Go templating via `{{ env "VAR_NAME" }}` syntax
- All template strings are properly quoted for YAML compatibility
- The `prepend_name` logic from Dagger is preserved (e.g., `library/` prefix)

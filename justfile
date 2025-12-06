# Infrastructure Setup Justfile

# Default recipe - show available commands
default:
    @just --list

# Check for available upgrades from Dependabot PRs
upgrade:
    uv run python -m infra_setup.cli upgrade --repo noroutine/upstream

# Apply available upgrades to variables.yml
upgrade-apply:
    uv run python -m infra_setup.cli upgrade --repo noroutine/upstream --apply

# Import all artifacts (images and charts)
import: import-images import-charts

# Import images using regsync
import-images:
    uv run python -m infra_setup.cli import-images

# Import Helm charts
import-charts:
    uv run python -m infra_setup.cli import-charts

# List all images that would be imported
list-images:
    uv run python -m infra_setup.cli list-images

# Generate artifacts (Dockerfile and infra.json)
generate-artifacts:
    uv run python -m infra_setup.cli generate-artifacts

# Show infrastructure summary
summary:
    uv run python -m infra_setup.cli summary

# Retag components
retag-components:
    uv run python -m infra_setup.cli retag-components

# Archive images (upstream mode - regsync only)
archive-upstream:
    uv run python -m infra_setup.cli archive-images --mode upstream

# Archive images (complete mode - regsync + components + builds)
archive-complete:
    uv run python -m infra_setup.cli archive-images --mode complete

# Analyze imported Helm charts
analyze-charts:
    uv run python -m infra_setup.cli analyze-charts --show-dependencies

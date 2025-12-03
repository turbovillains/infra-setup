"""Regsync configuration parser and utilities."""

import os
import re
from pathlib import Path
from typing import Any

import yaml


def load_variables(variables_file: str = "variables.yml") -> dict[str, str]:
    """Load variables from variables.yml."""
    with open(variables_file) as f:
        data = yaml.safe_load(f)
    return data.get("variables", {})


def expand_env_template(template: str, variables: dict[str, str], target_registry: str) -> str:
    """Expand {{ env "VAR" }} templates in a string."""

    def replacer(match: re.Match) -> str:
        var_name = match.group(1)
        if var_name == "TARGET_REGISTRY":
            return target_registry
        return variables.get(var_name, "")

    # Match {{ env "VARIABLE_NAME" }}
    pattern = r'\{\{\s*env\s+"([^"]+)"\s*\}\}'
    return re.sub(pattern, replacer, template)


def parse_regsync_config(
    regsync_file: str = "regsync.yml",
    variables_file: str = "variables.yml",
    target_registry: str = "cr.noroutine.me",
) -> list[dict[str, str]]:
    """
    Parse regsync.yml and return expanded image entries.

    Returns:
        List of dicts with 'source', 'target', 'type' keys
    """
    # Load variables
    variables = load_variables(variables_file)

    # Load regsync config
    with open(regsync_file) as f:
        config = yaml.safe_load(f)

    entries = []
    for sync_entry in config.get("sync", []):
        if sync_entry.get("type") != "image":
            continue

        source_template = sync_entry.get("source", "")
        target_template = sync_entry.get("target", "")

        # Expand templates
        source = expand_env_template(source_template, variables, target_registry)
        target = expand_env_template(target_template, variables, target_registry)

        entries.append({
            "source": source,
            "target": target,
            "type": "image",
        })

    return entries


def generate_dockerfile(entries: list[dict[str, str]]) -> str:
    """Generate Dockerfile content from image entries."""
    lines = []
    for entry in entries:
        source = entry["source"]
        # Extract image name for comment
        image_name = source.split(":")[0]
        lines.append(f"# {image_name}")
        lines.append(f"FROM {source}")
        lines.append(f"# {image_name}")
        lines.append("")

    return "\n".join(lines)


def generate_infra_json(entries: list[dict[str, str]], version: str = "dev") -> dict[str, Any]:
    """Generate infra.json content from image entries."""
    upstream_images = [entry["source"] for entry in entries]

    return {
        "version": version,
        "upstream": {
            "images": upstream_images,
        },
    }

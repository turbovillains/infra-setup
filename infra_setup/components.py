"""Component retagging utilities."""

import os
import re
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Any

import yaml

from .regsync import load_variables


def load_components(components_file: str = "components.yml") -> dict[str, Any]:
    """Load components from components.yml."""
    with open(components_file) as f:
        config = yaml.safe_load(f)
    return config.get("components", {})


def expand_version_template(template: str, variables: dict[str, str]) -> str:
    """
    Expand ${VAR} templates in version string.

    Args:
        template: Version template with ${VAR} syntax
        variables: Dictionary of variable values

    Returns:
        Expanded version string
    """
    # Replace ${VAR} with values from variables
    def replacer(match):
        var_name = match.group(1)
        return variables.get(var_name, match.group(0))

    return re.sub(r'\$\{([^}]+)\}', replacer, template)


def retag_component(
    component: str,
    image_base: str,
    image_version: str,
    registry: str,
    namespace: str,
    version: str,
) -> tuple[bool, str]:
    """
    Retag a single component using regctl.

    Args:
        component: Component name
        image_base: Source image path
        image_version: Source image version
        registry: Target registry
        namespace: Target namespace
        version: Target version tag

    Returns:
        Tuple of (success, error_message)
    """
    source = f"{registry}/{image_base}:{image_version}"
    destination = f"{registry}/{namespace}/{component}:{version}"

    try:
        # Use regctl to copy image (preserves all architectures)
        subprocess.run(
            ["regctl", "image", "copy", source, destination],
            check=True,
            capture_output=True,
            text=True,
        )
        return (True, "")
    except subprocess.CalledProcessError as e:
        return (False, f"regctl failed: {e.stderr.strip()}")
    except FileNotFoundError:
        return (False, "regctl not found - install regclient tools")


def get_compose_services(compose_file: Path, env_vars: dict[str, str]) -> list[str]:
    """
    Get list of services from a docker-compose file.

    Args:
        compose_file: Path to docker-compose file
        env_vars: Environment variables for docker-compose

    Returns:
        List of service names
    """
    try:
        result = subprocess.run(
            ["docker", "compose", "-f", str(compose_file), "config", "--services"],
            capture_output=True,
            text=True,
            check=True,
            env={**os.environ, **env_vars},
        )
        return [s for s in result.stdout.strip().split("\n") if s]
    except subprocess.CalledProcessError:
        return []


def discover_stages(base_dir: Path = Path(".")) -> list[str]:
    """
    Discover available build stages from docker-compose.*.yml files.

    Args:
        base_dir: Directory to search for compose files

    Returns:
        List of stage names
    """
    stages = []
    for file in base_dir.glob("docker-compose.*.yml"):
        # Extract stage name from docker-compose.STAGE.yml
        stage = file.stem.replace("docker-compose.", "")
        stages.append(stage)
    return sorted(stages)


def build_stage(
    stage: str,
    registry: str,
    namespace: str,
    version: str,
    push: bool = False,
    components: list[str] | None = None,
    multiarch: bool | None = None,
    extra_args: str = "",
) -> tuple[bool, str]:
    """
    Build images for a stage using docker buildx bake.

    Args:
        stage: Stage name (e.g., 'scratch', 'custom')
        registry: Container registry
        namespace: Image namespace
        version: Image version tag
        push: Whether to push images
        components: Specific components to build (None = all)
        multiarch: Force multiarch build (None = auto-detect from version)
        extra_args: Extra arguments for docker buildx bake

    Returns:
        Tuple of (success, error_message)
    """
    compose_file = f"docker-compose.{stage}.yml"

    if not Path(compose_file).exists():
        return (False, f"Compose file not found: {compose_file}")

    # Auto-detect tag builds (semver-like versions)
    is_tag_build = bool(re.match(r'^v?[0-9]+\.[0-9]+\.[0-9]+', version))

    # Determine multiarch setting
    if multiarch is None:
        # Default: multiarch for tag builds, single-arch for dev
        use_multiarch = is_tag_build
    else:
        use_multiarch = multiarch

    # Build docker buildx bake command
    cmd = ["docker", "buildx", "bake", "-f", compose_file]

    # Add platform override for single-arch builds
    if not use_multiarch:
        import platform
        arch = platform.machine()
        if arch == "x86_64":
            plat = "linux/amd64"
        elif arch in ("aarch64", "arm64"):
            plat = "linux/arm64"
        else:
            plat = f"linux/{arch}"
        cmd.extend(["--set", f"*.platform={plat}"])

    # Add component filter
    if components:
        cmd.extend(components)

    # Add extra args
    if extra_args:
        cmd.extend(extra_args.split())

    # Add push or load
    if push:
        cmd.append("--push")
    else:
        cmd.append("--load")

    try:
        subprocess.run(
            cmd,
            check=True,
            env=os.environ.copy(),
        )
        return (True, "")
    except subprocess.CalledProcessError as e:
        return (False, f"docker buildx bake failed with exit code {e.returncode}")
    except FileNotFoundError:
        return (False, "docker not found")

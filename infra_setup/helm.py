"""Helm chart import utilities."""

import re
import subprocess
from pathlib import Path
from typing import Any

import requests
import yaml
from packaging import version as pkg_version


def is_stable_version(version: str) -> bool:
    """Check if version is stable (not beta, alpha, dev, etc.)."""
    unstable_patterns = [
        "beta", "alpha", "dev", "test", "canary",
        "nightly", "dirty", "rc", "preview"
    ]
    version_lower = version.lower()
    return not any(pattern in version_lower for pattern in unstable_patterns)


def sort_versions(versions: list[str], reverse: bool = True) -> list[str]:
    """Sort versions using packaging.version for proper semantic versioning."""
    def version_key(v: str) -> tuple:
        # Remove 'v' prefix if present
        clean_v = v.lstrip('v')
        try:
            return (0, pkg_version.parse(clean_v))
        except Exception:
            # If parsing fails, fall back to string sorting
            return (1, clean_v)

    return sorted(versions, key=version_key, reverse=reverse)


def get_http_chart_versions(
    repo_url: str,
    chart_name: str,
    by_field: str = "version",
    limit: int = 10,
) -> list[str]:
    """
    Get chart versions from HTTP Helm repository.

    Args:
        repo_url: Repository URL
        chart_name: Chart name
        by_field: Sort by 'version' or 'created'
        limit: Number of versions to return

    Returns:
        List of version strings

    Raises:
        Exception: If fetching or parsing fails (with context)
    """
    try:
        # Fetch index.yaml
        index_url = f"{repo_url.rstrip('/')}/index.yaml"
        response = requests.get(index_url, timeout=30)
        response.raise_for_status()

        # Try to parse YAML - first with safe_load, then with FullLoader if that fails
        try:
            index = yaml.safe_load(response.text)
        except yaml.YAMLError:
            # safe_load failed, try FullLoader (handles more cases but still safe)
            # Also strip C1 control characters (0x80-0x9F) that might cause issues
            cleaned_text = re.sub(r'[\x80-\x9f]', '', response.text)
            index = yaml.load(cleaned_text, Loader=yaml.FullLoader)
    except requests.RequestException as e:
        raise Exception(f"Failed to fetch index from {repo_url}: {e}") from e
    except yaml.YAMLError as e:
        raise Exception(f"Failed to parse YAML from {repo_url}/index.yaml: {e}") from e
    entries = index.get("entries", {}).get(chart_name, [])

    # Filter stable versions
    stable_entries = [e for e in entries if is_stable_version(e.get("version", ""))]

    if by_field == "created":
        # Sort by created date
        stable_entries.sort(
            key=lambda e: e.get("created", ""),
            reverse=True
        )
    else:
        # Sort by version
        versions = [e["version"] for e in stable_entries]
        sorted_versions = sort_versions(versions, reverse=True)
        # Rebuild entries in sorted order
        version_to_entry = {e["version"]: e for e in stable_entries}
        stable_entries = [version_to_entry[v] for v in sorted_versions if v in version_to_entry]

    # Return top N versions
    return [e["version"] for e in stable_entries[:limit]]


def get_oci_chart_versions(
    oci_url: str,
    chart_name: str,
    limit: int = 10,
) -> list[str]:
    """
    Get chart versions from OCI registry using regctl.

    Args:
        oci_url: OCI repository URL (e.g., oci://ghcr.io/owner/repo/)
        chart_name: Chart name
        limit: Number of versions to return

    Returns:
        List of version strings
    """
    # Remove oci:// prefix
    registry_path = oci_url.replace("oci://", "").rstrip("/")
    full_path = f"{registry_path}/{chart_name}"

    try:
        # Use regctl to list tags
        result = subprocess.run(
            ["regctl", "tag", "list", full_path],
            capture_output=True,
            text=True,
            check=True,
        )

        tags = result.stdout.strip().split("\n")
        tags = [t for t in tags if t]  # Remove empty strings

        # Filter stable versions and sort
        stable_tags = [t for t in tags if is_stable_version(t)]
        sorted_tags = sort_versions(stable_tags, reverse=True)

        return sorted_tags[:limit]

    except subprocess.CalledProcessError as e:
        print(f"Warning: Failed to list OCI tags for {full_path}: {e.stderr}")
        return []
    except FileNotFoundError:
        print("Warning: regctl not found. Install regclient tools for OCI support.")
        return []


def detect_chart_filename(target_dir: Path, chart_name: str, version: str) -> str | None:
    """
    Detect the actual filename of a pulled chart.

    Some charts have different filenames than their chart name (e.g., node-feature-discovery-chart).

    Args:
        target_dir: Directory where chart was pulled
        chart_name: Chart name
        version: Chart version

    Returns:
        Actual filename without .tgz extension, or None if not found
    """
    # Common patterns
    patterns = [
        f"{chart_name}-{version}.tgz",          # Standard: chart-version.tgz
        f"{chart_name}-chart-{version}.tgz",    # With -chart suffix
        f"{chart_name}_chart-{version}.tgz",    # With _chart suffix
    ]

    for pattern in patterns:
        if (target_dir / pattern).exists():
            return pattern.replace(".tgz", "")

    # Fallback: Find any .tgz file with the version
    for file in target_dir.glob(f"*{version}.tgz"):
        return file.stem  # Return without extension

    return None


def pull_chart(
    repo_url: str,
    chart_name: str,
    version: str,
    target_dir: Path,
    repo_type: str = "http",
) -> tuple[bool, str, bool]:
    """
    Pull a Helm chart.

    Args:
        repo_url: Repository URL
        chart_name: Chart name
        version: Chart version
        target_dir: Target directory
        repo_type: Repository type ('http', 'https', or 'oci')

    Returns:
        Tuple of (success, actual_filename_base, was_cached)
    """
    target_dir.mkdir(parents=True, exist_ok=True)

    # Check if chart already exists with any known filename pattern
    existing = detect_chart_filename(target_dir, chart_name, version)
    if existing:
        return (True, existing, True)  # Already cached

    # Pull the chart
    try:
        if repo_type == "oci":
            # OCI registry
            cmd = [
                "helm", "pull",
                "--devel",
                f"{repo_url.rstrip('/')}/{chart_name}",
                "--destination", str(target_dir),
                "--version", version,
            ]
        else:
            # HTTP/HTTPS registry
            cmd = [
                "helm", "pull",
                "--repo", repo_url,
                "--destination", str(target_dir),
                "--version", version,
                chart_name,
            ]

        subprocess.run(cmd, check=True, capture_output=True, text=True)

        # Detect the actual filename after pulling
        actual = detect_chart_filename(target_dir, chart_name, version)
        return (True, actual or f"{chart_name}-{version}", False)  # Freshly downloaded

    except subprocess.CalledProcessError as e:
        print(f"Error pulling {chart_name}@{version}: {e.stderr}")
        return (False, "", False)


def create_helm_index(repo_dir: Path):
    """Create helm index for a repository directory."""
    try:
        subprocess.run(
            ["helm", "repo", "index", str(repo_dir)],
            check=True,
            capture_output=True,
            text=True,
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error creating index for {repo_dir}: {e.stderr}")
        return False

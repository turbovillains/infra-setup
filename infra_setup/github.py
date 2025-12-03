"""GitHub integration utilities."""

import re
from typing import Any

import requests


def get_dependabot_prs(repo: str, state: str = "open", github_token: str | None = None) -> list[dict[str, Any]]:
    """
    Fetch Dependabot pull requests from a GitHub repository.

    Args:
        repo: Repository in format "owner/repo"
        state: PR state - "open", "closed", or "all"
        github_token: Optional GitHub token for API access

    Returns:
        List of PR dictionaries with Dependabot PRs
    """
    headers = {"Accept": "application/vnd.github.v3+json"}
    if github_token:
        headers["Authorization"] = f"token {github_token}"

    url = f"https://api.github.com/repos/{repo}/pulls"
    params = {"state": state, "per_page": 100}

    try:
        response = requests.get(url, headers=headers, params=params, timeout=30)
        response.raise_for_status()
        all_prs = response.json()

        # Filter for Dependabot PRs (have "dependencies" and "docker" labels)
        dependabot_prs = []
        for pr in all_prs:
            labels = [label["name"].lower() for label in pr.get("labels", [])]
            if "dependencies" in labels and "docker" in labels:
                dependabot_prs.append(pr)

        return dependabot_prs

    except requests.RequestException as e:
        raise Exception(f"Failed to fetch PRs from {repo}: {e}") from e


def parse_dependabot_title(title: str) -> tuple[str | None, str | None, str | None]:
    """
    Parse Dependabot PR title to extract image name and versions.

    Common formats:
    - "Bump postgres from 16.1 to 16.2"
    - "Update redis Docker tag to v7.2.4"
    - "Bump library/alpine from 3.18 to 3.19"

    Args:
        title: PR title string

    Returns:
        Tuple of (image_name, old_version, new_version) or (None, None, None) if parsing fails
    """
    # Pattern 1: "Bump <image> from <old> to <new>"
    match = re.search(r'Bump\s+(.+?)\s+from\s+(.+?)\s+to\s+(.+?)$', title, re.IGNORECASE)
    if match:
        image = match.group(1).strip()
        old_version = match.group(2).strip()
        new_version = match.group(3).strip()
        return (image, old_version, new_version)

    # Pattern 2: "Update <image> Docker tag to <new>"
    match = re.search(r'Update\s+(.+?)\s+Docker\s+tag\s+to\s+(.+?)$', title, re.IGNORECASE)
    if match:
        image = match.group(1).strip()
        new_version = match.group(2).strip()
        return (image, None, new_version)

    return (None, None, None)


def normalize_image_name(image: str) -> str:
    """
    Normalize image name for matching.

    - Remove 'library/' prefix
    - Convert to lowercase
    - Handle common variations

    Args:
        image: Image name

    Returns:
        Normalized image name
    """
    normalized = image.lower()

    # Remove library/ prefix (Docker Hub official images)
    if normalized.startswith("library/"):
        normalized = normalized[8:]

    return normalized

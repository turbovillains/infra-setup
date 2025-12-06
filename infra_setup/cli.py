"""CLI for infrastructure setup operations."""

import json
import os
import re
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path
from typing import Optional

import typer
from rich.console import Console
from rich.table import Table
from rich.panel import Panel

from .regsync import (
    parse_regsync_config,
    generate_dockerfile,
    generate_infra_json,
    load_variables,
)
from .helm import (
    get_http_chart_versions,
    get_oci_chart_versions,
    pull_chart,
    create_helm_index,
)
from .components import (
    load_components,
    expand_version_template,
    retag_component,
    discover_stages,
    build_stage,
    get_compose_services,
)
from .github import (
    get_dependabot_prs,
    parse_dependabot_title,
    normalize_image_name,
)

app = typer.Typer(
    name="infra",
    help="Infrastructure image management and artifact generation",
    add_completion=False,
    invoke_without_command=True,
)
console = Console(width=120)  # Wider console to prevent wrapping


def get_git_versions() -> dict[str, str]:
    """
    Get git version information.

    Returns:
        Dict with current_sha, last_tag, and next_version
    """
    versions = {
        "current_sha": "unknown",
        "last_tag": "none",
        "next_version": "v0.1.0",
    }

    try:
        # Current commit SHA
        result = subprocess.run(
            ["git", "rev-parse", "--short=8", "HEAD"],
            capture_output=True,
            text=True,
            check=True,
        )
        versions["current_sha"] = result.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass

    try:
        # Last tag (semver sorted)
        result = subprocess.run(
            ["git", "tag", "--sort=-version:refname"],
            capture_output=True,
            text=True,
            check=True,
        )
        tags = [t for t in result.stdout.strip().split("\n") if t]
        if tags:
            last_tag = tags[0]
            versions["last_tag"] = last_tag

            # Calculate next version (increment patch)
            # Try full semver first (major.minor.patch)
            match = re.match(r'^v?(\d+)\.(\d+)\.(\d+)', last_tag)
            if match:
                major, minor, patch = map(int, match.groups())
                versions["next_version"] = f"v{major}.{minor}.{patch + 1}"
            else:
                # Try major.minor format
                match = re.match(r'^v?(\d+)\.(\d+)', last_tag)
                if match:
                    major, minor = map(int, match.groups())
                    versions["next_version"] = f"v{major}.{minor}.1"
                else:
                    versions["next_version"] = "v0.1.0"
    except (subprocess.CalledProcessError, FileNotFoundError):
        pass

    return versions


@app.command()
def import_images(
    regsync_config: str = typer.Option("regsync.yml", "--config", "-c", help="Path to regsync.yml"),
    variables_file: str = typer.Option("variables.yml", "--variables", "-v", help="Path to variables.yml"),
    target_registry: str = typer.Option("cr.noroutine.me", "--registry", "-r", help="Target registry"),
    verbosity: str = typer.Option("info", "--verbosity", help="Regsync verbosity level"),
):
    """Import images using regsync."""
    console.print(Panel.fit("🚀 Importing Images", style="bold blue"))

    # Load and export variables as environment variables
    variables = load_variables(variables_file)

    console.print(f"[dim]Loaded {len(variables)} variables from {variables_file}[/dim]")
    console.print(f"[dim]Target registry: {target_registry}[/dim]")

    # Build environment with variables (inherit current environment)
    env = os.environ.copy()
    env.update(variables)
    env["TARGET_REGISTRY"] = target_registry

    # Run regsync
    cmd = ["regsync", "once", "-c", regsync_config, "-v", verbosity]

    console.print(f"\n[bold]Running:[/bold] [cyan]{' '.join(cmd)}[/cyan]")

    try:
        result = subprocess.run(
            cmd,
            env=env,
            check=True,
            text=True,
        )
        console.print("\n[green]✓ Images imported successfully[/green]")
        return result.returncode
    except subprocess.CalledProcessError as e:
        console.print(f"\n[red]✗ Import failed with exit code {e.returncode}[/red]")
        raise typer.Exit(code=e.returncode)
    except FileNotFoundError:
        console.print("[red]✗ regsync not found. Please install regclient tools.[/red]")
        raise typer.Exit(code=1)


@app.command()
def list_images(
    regsync_config: str = typer.Option("regsync.yml", "--config", "-c", help="Path to regsync.yml"),
    variables_file: str = typer.Option("variables.yml", "--variables", "-v", help="Path to variables.yml"),
    target_registry: str = typer.Option("cr.noroutine.me", "--registry", "-r", help="Target registry"),
    pattern: Optional[str] = typer.Option(None, "--pattern", "-p", help="Filter images by pattern"),
):
    """List all images that would be imported."""
    console.print(Panel.fit("📋 Image List", style="bold blue"))

    # Parse regsync config
    entries = parse_regsync_config(regsync_config, variables_file, target_registry)

    # Filter by pattern if provided
    if pattern:
        entries = [e for e in entries if pattern in e["source"] or pattern in e["target"]]
        console.print(f"[dim]Filter: {pattern}[/dim]\n")

    # Create table
    table = Table(show_header=True, header_style="bold cyan")
    table.add_column("Source", style="yellow", no_wrap=False)
    table.add_column("→", style="dim", justify="center", width=3)
    table.add_column("Target", style="green", no_wrap=False)

    for entry in entries:
        table.add_row(entry["source"], "→", entry["target"])

    console.print(table)
    console.print(f"\n[bold]Total:[/bold] {len(entries)} image(s)")


@app.command()
def generate_artifacts(
    output_dir: str = typer.Option("./artifacts", "--output", "-o", help="Output directory for artifacts"),
    regsync_config: str = typer.Option("regsync.yml", "--config", "-c", help="Path to regsync.yml"),
    variables_file: str = typer.Option("variables.yml", "--variables", "-v", help="Path to variables.yml"),
    target_registry: str = typer.Option("cr.noroutine.me", "--registry", "-r", help="Target registry"),
    infra_version: str = typer.Option("dev", "--version", help="Infrastructure version"),
):
    """Generate Dockerfile and infra.json artifacts for dependency tracking."""
    console.print(Panel.fit("📦 Generating Artifacts", style="bold blue"))

    # Parse regsync config
    entries = parse_regsync_config(regsync_config, variables_file, target_registry)

    console.print(f"[dim]Parsed {len(entries)} images from {regsync_config}[/dim]")
    console.print(f"[dim]Version: {infra_version}[/dim]")

    # Create output directory
    output_path = Path(output_dir)
    output_path.mkdir(parents=True, exist_ok=True)

    # Generate Dockerfile
    dockerfile_content = generate_dockerfile(entries)
    dockerfile_path = output_path / "Dockerfile"
    dockerfile_path.write_text(dockerfile_content)
    console.print(f"[green]✓[/green] Generated {dockerfile_path}")

    # Generate infra.json
    infra_json = generate_infra_json(entries, infra_version)
    infra_json_path = output_path / "infra.json"
    infra_json_path.write_text(json.dumps(infra_json, indent=2) + "\n")
    console.print(f"[green]✓[/green] Generated {infra_json_path}")

    console.print(f"\n[bold green]✓ Artifacts generated in {output_dir}[/bold green]")


@app.command()
def import_charts(
    config_file: str = typer.Option("import-charts.yml", "--config", "-c", help="Path to import-charts.yml"),
    target_dir: str = typer.Option("./docker/infra-charts/charts", "--target", "-t", help="Target directory for charts"),
    limit: int = typer.Option(10, "--limit", "-l", help="Number of versions per chart"),
    parallel: bool = typer.Option(True, "--parallel/--sequential", help="Pull charts in parallel"),
):
    """Import Helm charts from configured repositories."""
    import yaml
    from concurrent.futures import ThreadPoolExecutor, as_completed

    console.print(Panel.fit("📦 Importing Helm Charts", style="bold blue"))

    # Load configuration
    with open(config_file) as f:
        config = yaml.safe_load(f)

    repos = config.get("helm", [])
    console.print(f"[dim]Found {len(repos)} repositories in {config_file}[/dim]")

    target_path = Path(target_dir)
    total_charts = 0
    total_downloaded = 0
    total_cached = 0
    errors = []

    def process_chart(repo_name: str, repo_uri: str, repo_type: str, chart_config: dict) -> tuple[int, int, int, list[str]]:
        """Process a single chart. Returns (charts_count, downloaded_count, cached_count, errors)."""
        chart_name = chart_config.get("name")
        chart_errors = []

        if not chart_name:
            return (0, 0, 0, chart_errors)

        try:
            explicit_versions = chart_config.get("version")
            by_field = chart_config.get("by", "version")

            # Get versions
            if explicit_versions:
                # Explicit version(s) provided
                if isinstance(explicit_versions, str):
                    versions = [explicit_versions]
                else:
                    versions = explicit_versions if isinstance(explicit_versions, list) else [str(explicit_versions)]
            else:
                # Auto-discover versions
                if repo_type == "oci":
                    console.print(f"[yellow]⚠[/yellow]  Discovering OCI versions for {repo_name}/{chart_name}")
                    versions = get_oci_chart_versions(repo_uri, chart_name, limit=limit)
                    if not versions:
                        error_msg = f"No versions found for OCI chart {repo_name}/{chart_name}"
                        console.print(f"[red]✗[/red] {error_msg}")
                        chart_errors.append(error_msg)
                        return (0, 0, 0, chart_errors)
                else:
                    versions = get_http_chart_versions(repo_uri, chart_name, by_field=by_field, limit=limit)

            if not versions:
                console.print(f"[yellow]⚠[/yellow]  No versions to import for {chart_name}")
                return (0, 0, 0, chart_errors)
        except Exception as e:
            error_msg = f"{repo_name}/{chart_name}: {str(e)}"
            console.print(f"[red]✗ Error discovering versions for {repo_name}/{chart_name}:[/red]")
            console.print(f"  [dim]{str(e)}[/dim]")
            chart_errors.append(error_msg)
            return (0, 0, 0, chart_errors)

        console.print(f"[cyan]→[/cyan] {repo_name}/{chart_name}: {len(versions)} version(s) by {by_field}")

        # Pull each version
        repo_target = target_path / repo_name
        downloaded = 0
        cached = 0

        for ver in versions:
            try:
                success, filename, was_cached = pull_chart(repo_uri, chart_name, ver, repo_target, repo_type)
                if success:
                    if was_cached:
                        # Already existed
                        if filename == f"{chart_name}-{ver}":
                            console.print(f"  [dim]•[/dim] {chart_name}@{ver} [dim](cached)[/dim]")
                        else:
                            console.print(f"  [dim]•[/dim] {chart_name}@{ver} → {filename}.tgz [dim](cached)[/dim]")
                        cached += 1
                    else:
                        # Freshly downloaded
                        if filename == f"{chart_name}-{ver}":
                            console.print(f"  [green]✓[/green] {chart_name}@{ver} [green](downloaded)[/green]")
                        else:
                            console.print(f"  [green]✓[/green] {chart_name}@{ver} → {filename}.tgz [green](downloaded)[/green]")
                        downloaded += 1
                else:
                    error_msg = f"{repo_name}/{chart_name}@{ver}: pull failed"
                    console.print(f"  [red]✗[/red] {chart_name}@{ver} [red](failed)[/red]")
                    chart_errors.append(error_msg)
            except Exception as e:
                error_msg = f"{repo_name}/{chart_name}@{ver}: {str(e)[:80]}"
                console.print(f"  [red]✗ Error pulling {chart_name}@{ver}:[/red] {str(e)[:80]}")
                chart_errors.append(error_msg)

        return (1, downloaded, cached, chart_errors)

    # Process repositories
    if parallel:
        # Parallel processing
        with ThreadPoolExecutor(max_workers=10) as executor:
            futures = []

            for repo in repos:
                repo_name = repo.get("name")
                repo_uri = repo.get("uri", "").rstrip("/")
                repo_type = repo.get("type", "http")
                charts = repo.get("charts", [])

                if not charts:
                    # No specific charts, skip
                    continue

                for chart_config in charts:
                    future = executor.submit(
                        process_chart,
                        repo_name, repo_uri, repo_type, chart_config
                    )
                    futures.append(future)

            # Wait for all futures to complete
            for future in as_completed(futures):
                try:
                    charts_count, downloaded_count, cached_count, chart_errors = future.result()
                    total_charts += charts_count
                    total_downloaded += downloaded_count
                    total_cached += cached_count
                    errors.extend(chart_errors)
                except Exception as e:
                    error_msg = str(e)
                    console.print(f"[red]✗ Unexpected error:[/red] {error_msg[:100]}")
                    errors.append(f"Unexpected: {error_msg}")
    else:
        # Sequential processing
        for repo in repos:
            repo_name = repo.get("name")
            repo_uri = repo.get("uri", "").rstrip("/")
            repo_type = repo.get("type", "http")
            charts = repo.get("charts", [])

            if not charts:
                continue

            for chart_config in charts:
                charts_count, downloaded_count, cached_count, chart_errors = process_chart(
                    repo_name, repo_uri, repo_type, chart_config
                )
                total_charts += charts_count
                total_downloaded += downloaded_count
                total_cached += cached_count
                errors.extend(chart_errors)

    # Create helm indexes for each repo
    console.print("\n[bold]Creating Helm repository indexes...[/bold]")
    for repo_dir in target_path.iterdir():
        if repo_dir.is_dir():
            if create_helm_index(repo_dir):
                console.print(f"  [green]✓[/green] {repo_dir.name}")
            else:
                console.print(f"  [red]✗[/red] {repo_dir.name}")

    total_versions = total_downloaded + total_cached

    console.print(f"\n[bold green]✓ Processed {total_charts} charts:[/bold green]")
    console.print(f"  [green]Downloaded:[/green] {total_downloaded}")
    console.print(f"  [dim]Cached:[/dim] {total_cached}")
    console.print(f"  [bold]Total:[/bold] {total_versions} versions")

    if errors:
        console.print(f"\n[yellow]⚠ {len(errors)} error(s) occurred:[/yellow]")
        # Show first 5 errors
        for error in errors[:5]:
            console.print(f"  [dim]•[/dim] {error}")
        if len(errors) > 5:
            console.print(f"  [dim]... and {len(errors) - 5} more[/dim]")


@app.command()
def retag_components(
    components_file: str = typer.Option("components.yml", "--config", "-c", help="Path to components.yml"),
    variables_file: str = typer.Option("variables.yml", "--variables", "-v", help="Path to variables.yml"),
    target_registry: str = typer.Option("cr.noroutine.me", "--registry", "-r", help="Target registry"),
    namespace: str = typer.Option("infra-dev", "--namespace", "-n", help="Image namespace"),
    version: str = typer.Option(None, "--version", help="Image version tag (default: git 8-char SHA)"),
    components: Optional[str] = typer.Option(None, "--components", help="Comma-separated list of components to retag"),
    parallel: int = typer.Option(10, "--parallel", help="Number of parallel operations"),
):
    """Retag generic components using regctl."""
    console.print(Panel.fit("🔄 Retagging Components", style="bold blue"))

    # Determine version
    if not version:
        try:
            result = subprocess.run(
                ["git", "rev-parse", "--short=8", "HEAD"],
                capture_output=True,
                text=True,
                check=True,
            )
            version = result.stdout.strip()
        except (subprocess.CalledProcessError, FileNotFoundError):
            version = "dev"

    # Load variables and components
    variables = load_variables(variables_file)
    all_components = load_components(components_file)

    console.print(f"[dim]Loaded {len(variables)} variables from {variables_file}[/dim]")
    console.print(f"[dim]Found {len(all_components)} components in {components_file}[/dim]")

    # Filter components if specified
    if components:
        component_list = [c.strip() for c in components.split(",")]
        filtered = {k: v for k, v in all_components.items() if k in component_list}
        if not filtered:
            console.print(f"[red]✗ No matching components found[/red]")
            raise typer.Exit(code=1)
        all_components = filtered

    console.print(f"[dim]Registry: {target_registry}[/dim]")
    console.print(f"[dim]Namespace: {namespace}[/dim]")
    console.print(f"[dim]Version: {version}[/dim]")
    console.print(f"[dim]Parallel: {parallel}[/dim]\n")

    # Process components in parallel
    def process_component(comp_name: str, comp_config: dict) -> tuple[str, bool, str]:
        """Process a single component. Returns (name, success, error)."""
        image_base = comp_config.get("image_base")
        image_version_template = comp_config.get("image_version")

        if not image_base or not image_version_template:
            return (comp_name, False, "Missing image_base or image_version")

        # Expand version template
        image_version = expand_version_template(image_version_template, variables)

        # Retag component
        success, error = retag_component(
            comp_name,
            image_base,
            image_version,
            target_registry,
            namespace,
            version,
        )

        return (comp_name, success, error)

    console.print(f"[bold]Retagging {len(all_components)} components...[/bold]\n")

    succeeded = 0
    failed = 0
    errors = []

    with ThreadPoolExecutor(max_workers=parallel) as executor:
        futures = [
            executor.submit(process_component, name, config)
            for name, config in all_components.items()
        ]

        for future in as_completed(futures):
            try:
                comp_name, success, error = future.result()
                if success:
                    console.print(f"  [green]✓[/green] {comp_name}")
                    succeeded += 1
                else:
                    console.print(f"  [red]✗[/red] {comp_name} [dim]({error})[/dim]")
                    failed += 1
                    errors.append(f"{comp_name}: {error}")
            except Exception as e:
                console.print(f"  [red]✗[/red] Unexpected error: {str(e)[:80]}")
                failed += 1

    console.print(f"\n[bold green]✓ Retagging complete:[/bold green]")
    console.print(f"  [green]Succeeded:[/green] {succeeded}")
    if failed > 0:
        console.print(f"  [red]Failed:[/red] {failed}")

    if errors:
        console.print(f"\n[yellow]⚠ {len(errors)} error(s):[/yellow]")
        for error in errors[:5]:
            console.print(f"  [dim]•[/dim] {error}")
        if len(errors) > 5:
            console.print(f"  [dim]... and {len(errors) - 5} more[/dim]")

    if failed > 0:
        raise typer.Exit(code=1)


@app.command(name="build-stage")
def build_stage_cmd(
    stage: str = typer.Argument(..., help="Build stage (e.g., scratch, custom)"),
    target_registry: str = typer.Option("cr.noroutine.me", "--registry", "-r", help="Target registry"),
    namespace: str = typer.Option("infra-dev", "--namespace", "-n", help="Image namespace"),
    version: str = typer.Option(None, "--version", help="Image version tag (default: git 8-char SHA)"),
    push: bool = typer.Option(False, "--push", help="Push images after build"),
    components: Optional[str] = typer.Option(None, "--components", help="Comma-separated list of components to build"),
    multiarch: Optional[bool] = typer.Option(None, "--multiarch/--no-multiarch", help="Force multiarch build"),
    extra_args: str = typer.Option("", "--bake-args", help="Extra arguments for docker buildx bake"),
    variables_file: str = typer.Option("variables.yml", "--variables", "-v", help="Path to variables.yml"),
):
    """Build container images for a stage using docker buildx bake."""
    console.print(Panel.fit(f"🔨 Building {stage.upper()} Stage", style="bold blue"))

    # Determine version
    if not version:
        try:
            result = subprocess.run(
                ["git", "rev-parse", "--short=8", "HEAD"],
                capture_output=True,
                text=True,
                check=True,
            )
            version = result.stdout.strip()
        except (subprocess.CalledProcessError, FileNotFoundError):
            version = "dev"

    # Load and export variables
    variables = load_variables(variables_file)
    env = os.environ.copy()
    env.update(variables)
    env["IMAGE_REGISTRY"] = target_registry
    env["INFRA_NAMESPACE"] = namespace
    env["INFRA_VERSION"] = version

    # Update environment for subprocess
    os.environ.update(env)

    console.print(f"[dim]Registry: {target_registry}[/dim]")
    console.print(f"[dim]Namespace: {namespace}[/dim]")
    console.print(f"[dim]Version: {version}[/dim]")
    console.print(f"[dim]Push: {push}[/dim]")

    # Check if multiarch
    is_tag = bool(re.match(r'^v?[0-9]+\.[0-9]+\.[0-9]+', version))
    use_multiarch = multiarch if multiarch is not None else is_tag

    if use_multiarch:
        console.print(f"[dim]Platforms: Multi-arch (linux/amd64, linux/arm64)[/dim]")
    else:
        console.print(f"[dim]Platforms: Single-arch (current platform)[/dim]")

    if components:
        console.print(f"[dim]Components: {components}[/dim]")

    console.print()

    # Parse components
    component_list = [c.strip() for c in components.split(",")] if components else None

    # Build stage
    success, error = build_stage(
        stage=stage,
        registry=target_registry,
        namespace=namespace,
        version=version,
        push=push,
        components=component_list,
        multiarch=use_multiarch,
        extra_args=extra_args,
    )

    if success:
        console.print(f"\n[bold green]✓ {stage.capitalize()} stage build completed![/bold green]")
    else:
        console.print(f"\n[red]✗ Build failed: {error}[/red]")
        raise typer.Exit(code=1)


@app.callback()
def main(ctx: typer.Context):
    """Infrastructure image management and artifact generation."""
    # If no command is specified, run summary
    if ctx.invoked_subcommand is None:
        summary(
            variables_file="variables.yml",
            components_file="components.yml",
            charts_file="import-charts.yml",
        )


@app.command()
def summary(
    variables_file: str = typer.Option("variables.yml", "--variables", "-v", help="Path to variables.yml"),
    components_file: str = typer.Option("components.yml", "--config", "-c", help="Path to components.yml"),
    charts_file: str = typer.Option("import-charts.yml", "--charts", help="Path to import-charts.yml"),
):
    """Show summary of infrastructure configuration."""
    import yaml

    console.print(Panel.fit("📊 Infrastructure Setup Summary", style="bold blue"))

    # Git version information
    versions = get_git_versions()
    console.print(f"\n[bold cyan]Version Information:[/bold cyan]")
    console.print(f"  Current commit: [yellow]{versions['current_sha']}[/yellow]")
    console.print(f"  Last tag:       [green]{versions['last_tag']}[/green]")
    console.print(f"  Next version:   [blue]{versions['next_version']}[/blue]")

    # Variables
    try:
        variables = load_variables(variables_file)
        console.print(f"\n[bold cyan]Variables ({variables_file}):[/bold cyan]")
        console.print(f"  Total: {len(variables)} variables")

        # Show first few variables as examples
        sample = list(variables.items())[:5]
        for key, value in sample:
            console.print(f"  [dim]•[/dim] {key}=[yellow]{value}[/yellow]")
        if len(variables) > 5:
            console.print(f"  [dim]... and {len(variables) - 5} more[/dim]")
    except Exception as e:
        console.print(f"\n[red]✗ Could not load {variables_file}: {e}[/red]")

    # Components
    try:
        components = load_components(components_file)
        console.print(f"\n[bold cyan]Components ({components_file}):[/bold cyan]")
        console.print(f"  Total: {len(components)} components")

        # Show first few components
        sample = list(components.items())[:5]
        for name, config in sample:
            image_base = config.get("image_base", "?")
            console.print(f"  [dim]•[/dim] {name} [dim]({image_base})[/dim]")
        if len(components) > 5:
            console.print(f"  [dim]... and {len(components) - 5} more[/dim]")
    except Exception as e:
        console.print(f"\n[red]✗ Could not load {components_file}: {e}[/red]")

    # Charts
    try:
        with open(charts_file) as f:
            charts_config = yaml.safe_load(f)
        repos = charts_config.get("helm", [])
        total_charts = sum(len(r.get("charts", [])) for r in repos)

        console.print(f"\n[bold cyan]Helm Charts ({charts_file}):[/bold cyan]")
        console.print(f"  Repositories: {len(repos)}")
        console.print(f"  Total charts: {total_charts}")

        # Show repos
        for repo in repos[:5]:
            repo_name = repo.get("name", "?")
            chart_count = len(repo.get("charts", []))
            console.print(f"  [dim]•[/dim] {repo_name} [dim]({chart_count} charts)[/dim]")
        if len(repos) > 5:
            console.print(f"  [dim]... and {len(repos) - 5} more[/dim]")
    except FileNotFoundError:
        console.print(f"\n[yellow]⚠ {charts_file} not found[/yellow]")
    except Exception as e:
        console.print(f"\n[red]✗ Could not load {charts_file}: {e}[/red]")

    # Docker Compose Stages
    console.print(f"\n[bold cyan]Build Stages:[/bold cyan]")
    stages = discover_stages()

    if stages:
        # Load variables for docker-compose config
        variables = load_variables(variables_file)
        env_vars = {
            **variables,
            "IMAGE_REGISTRY": "cr.noroutine.me",
            "INFRA_NAMESPACE": "infra-dev",
            "INFRA_VERSION": "dev",
        }

        for stage in stages:
            compose_file = Path(f"docker-compose.{stage}.yml")
            services = get_compose_services(compose_file, env_vars)
            console.print(f"  [dim]•[/dim] {stage} [dim]({len(services)} services)[/dim]")
            for svc in services[:3]:
                console.print(f"    [dim]- {svc}[/dim]")
            if len(services) > 3:
                console.print(f"    [dim]... and {len(services) - 3} more[/dim]")
    else:
        console.print(f"  [yellow]⚠ No docker-compose.*.yml files found[/yellow]")

    console.print()


@app.command()
def archive_images(
    mode: str = typer.Option("upstream", "--mode", "-m", help="Archive mode: upstream (regsync only) or complete (regsync + components + builds)"),
    target_registry: str = typer.Option("cr.noroutine.me", "--registry", "-r", help="Target registry"),
    namespace: str = typer.Option("infra-dev", "--namespace", "-n", help="Image namespace"),
    version: str = typer.Option(None, "--version", help="Image version tag (default: current commit SHA)"),
    regsync_config: str = typer.Option("regsync.yml", "--regsync", help="Path to regsync.yml"),
    components_file: str = typer.Option("components.yml", "--config", "-c", help="Path to components.yml"),
    variables_file: str = typer.Option("variables.yml", "--variables", "-v", help="Path to variables.yml"),
    pattern: Optional[str] = typer.Option(None, "--pattern", "-p", help="Filter components by pattern"),
    batch_size: int = typer.Option(10, "--batch-size", "-b", help="Number of components per batch"),
    archive_dir: str = typer.Option("./archive", "--archive-dir", "-a", help="Archive directory"),
    storage_host: str = typer.Option("oleksii@mgmt02-vm-core01.noroutine.me", "--storage-host", help="Storage host for rsync"),
    storage_path: str = typer.Option("/mnt/data/infra", "--storage-path", help="Storage path on host"),
    upload: bool = typer.Option(False, "--upload", help="Upload archives to storage"),
    cleanup_after_upload: bool = typer.Option(False, "--cleanup-after-upload", help="Delete local archives after successful upload (saves disk space)"),
):
    """Archive images to OCI layout and optionally upload to storage."""
    import tempfile
    import yaml
    from pathlib import Path

    if mode not in ("upstream", "complete"):
        console.print(f"[red]✗ Invalid mode: {mode}. Use 'upstream' or 'complete'[/red]")
        raise typer.Exit(code=1)

    console.print(Panel.fit(f"📦 Archiving Images ({mode.upper()} mode)", style="bold blue"))

    # Determine version
    if not version:
        try:
            result = subprocess.run(
                ["git", "rev-parse", "--short=8", "HEAD"],
                capture_output=True,
                text=True,
                check=True,
            )
            version = result.stdout.strip()
        except (subprocess.CalledProcessError, FileNotFoundError):
            version = "dev"

    # Load variables
    variables = load_variables(variables_file)

    # Collect images to archive based on mode
    images_to_archive = []

    # 1. UPSTREAM: Images from regsync.yml
    console.print(f"[dim]Collecting upstream images from {regsync_config}...[/dim]")
    try:
        regsync_entries = parse_regsync_config(regsync_config, variables_file, target_registry)
        for entry in regsync_entries:
            # entry["target"] is like: cr.noroutine.me/library/debian:trixie-20251117-slim
            target_img = entry["target"]
            # Extract image name from target
            if "/" in target_img and ":" in target_img:
                parts = target_img.split("/", 2)  # registry / path:tag
                if len(parts) >= 2:
                    image_path = parts[-1]  # e.g., library/debian:version
                    if ":" in image_path:
                        name_part, tag_part = image_path.rsplit(":", 1)
                        # Normalize name for archive
                        archive_name = name_part.replace("/", "-")
                        images_to_archive.append({
                            "name": archive_name,
                            "source": target_img,
                            "type": "upstream",
                        })
        console.print(f"[dim]  Found {len(images_to_archive)} upstream images[/dim]")
    except Exception as e:
        console.print(f"[red]✗ Failed to load regsync config: {e}[/red]")
        raise typer.Exit(code=1)

    # 2. COMPLETE MODE: Add retagged components + built services
    if mode == "complete":
        # Add components (retagged)
        console.print(f"[dim]Collecting retagged components from {components_file}...[/dim]")
        components = load_components(components_file)
        for comp_name in components.keys():
            source = f"{target_registry}/{namespace}/{comp_name}:{version}"
            images_to_archive.append({
                "name": comp_name,
                "source": source,
                "type": "component",
            })
        console.print(f"[dim]  Found {len(components)} retagged components[/dim]")

        # Add built services from docker-compose stages
        console.print(f"[dim]Collecting built services from docker-compose stages...[/dim]")
        stages = discover_stages()
        env_vars = {
            **variables,
            "IMAGE_REGISTRY": target_registry,
            "INFRA_NAMESPACE": namespace,
            "INFRA_VERSION": version,
        }

        built_count = 0
        for stage in stages:
            compose_file = Path(f"docker-compose.{stage}.yml")
            services = get_compose_services(compose_file, env_vars)
            for svc in services:
                source = f"{target_registry}/{namespace}/{svc}:{version}"
                images_to_archive.append({
                    "name": svc,
                    "source": source,
                    "type": "built",
                })
                built_count += 1
        console.print(f"[dim]  Found {built_count} built services[/dim]")

    # Filter by pattern if specified
    if pattern:
        filtered = [img for img in images_to_archive if pattern in img["name"]]
        if not filtered:
            console.print(f"[red]✗ No images match pattern: {pattern}[/red]")
            raise typer.Exit(code=1)
        images_to_archive = filtered

    console.print(f"\n[dim]Registry: {target_registry}[/dim]")
    console.print(f"[dim]Namespace: {namespace}[/dim]")
    console.print(f"[dim]Version: {version}[/dim]")
    console.print(f"[dim]Total images: {len(images_to_archive)}[/dim]")
    console.print(f"[dim]Batch size: {batch_size}[/dim]")
    console.print(f"[dim]Archive dir: {archive_dir}[/dim]\n")

    archive_path = Path(archive_dir)
    archive_path.mkdir(parents=True, exist_ok=True)

    # Split into batches
    batches = [images_to_archive[i:i + batch_size] for i in range(0, len(images_to_archive), batch_size)]

    total_archived = 0
    total_batches = len(batches)
    restore_entries = []

    for batch_num, batch in enumerate(batches, 1):
        console.print(f"[bold]Batch {batch_num}/{total_batches}:[/bold] {len(batch)} images")

        # Generate temporary regsync config
        sync_entries = []
        batch_archive_dirs = []  # Track directories created in this batch

        for img in batch:
            img_name = img["name"]
            source = img["source"]

            # Extract version from source (after last :)
            if ":" in source:
                _, img_version = source.rsplit(":", 1)
            else:
                img_version = version

            # Target: ocidir://archive/registry-component-version-multiarch
            archive_name = f"{target_registry.replace('/', '-')}-{img_name}-{img_version}-multiarch"
            target = f"ocidir://{archive_path}/{archive_name}:{img_version}"

            sync_entries.append({
                "source": source,
                "target": target,
                "type": "image",
            })

            # Track directory for potential cleanup
            batch_archive_dirs.append(archive_path / archive_name)

            # Save for restore config (reverse)
            restore_entries.append({
                "source": f"ocidir://{archive_name}:{img_version}",
                "target": source,
                "type": "image",
                "name": img_name,
                "image_type": img["type"],
            })

        if not sync_entries:
            console.print(f"  [yellow]⚠[/yellow] No valid entries in batch {batch_num}")
            continue

        # Write temporary regsync config
        with tempfile.NamedTemporaryFile(mode='w', suffix='.yml', delete=False) as f:
            config = {"sync": sync_entries}
            yaml.dump(config, f, default_flow_style=False)
            temp_config = f.name

        try:
            # Run regsync to archive
            console.print(f"  [cyan]→[/cyan] Archiving {len(sync_entries)} images...")
            result = subprocess.run(
                ["regsync", "once", "-c", temp_config, "-v", "info"],
                capture_output=True,
                text=True,
                check=True,
            )

            for img in batch:
                img_name = img["name"]
                img_type = img["type"]
                console.print(f"    [green]✓[/green] {img_name} [dim]({img_type})[/dim]")
                total_archived += 1

        except subprocess.CalledProcessError as e:
            console.print(f"  [red]✗[/red] Batch {batch_num} failed: {e.stderr[:200]}")
        except FileNotFoundError:
            console.print("[red]✗ regsync not found. Install regclient tools.[/red]")
            raise typer.Exit(code=1)
        finally:
            # Clean up temp config
            Path(temp_config).unlink(missing_ok=True)

        # Upload batch to storage if requested
        if upload:
            console.print(f"  [cyan]→[/cyan] Uploading batch to storage...")
            storage_dest = f"{storage_host}:{storage_path}/{version}/images"

            try:
                # Add SSH host key if needed (first upload only)
                if batch_num == 1:
                    # Extract hostname from storage_host (user@host format)
                    hostname = storage_host.split("@")[-1] if "@" in storage_host else storage_host
                    subprocess.run(
                        ["ssh-keyscan", "-H", hostname],
                        stdout=open(os.path.expanduser("~/.ssh/known_hosts"), "a"),
                        stderr=subprocess.DEVNULL,
                        check=False,  # Don't fail if already exists
                    )

                # Create remote directory and rsync
                subprocess.run(
                    [
                        "rsync", "-av", "-e", "ssh -o StrictHostKeyChecking=accept-new",
                        "--rsync-path", f"sudo mkdir -p {storage_path}/{version}/images && sudo rsync",
                        f"{archive_path}/",
                        storage_dest,
                    ],
                    check=True,
                    capture_output=True,
                    text=True,
                )
                console.print(f"    [green]✓[/green] Uploaded to {storage_dest}")

                # Cleanup after successful upload if requested
                if cleanup_after_upload:
                    import shutil
                    console.print(f"    [cyan]→[/cyan] Cleaning up local archives...")
                    cleaned = 0
                    for archive_dir in batch_archive_dirs:
                        if archive_dir.exists():
                            shutil.rmtree(archive_dir)
                            cleaned += 1
                    console.print(f"    [green]✓[/green] Cleaned up {cleaned} directories (saved disk space)")

            except subprocess.CalledProcessError as e:
                console.print(f"    [red]✗[/red] Upload failed: {e.stderr[:200]}")
                console.print(f"    [red]Aborting due to upload failure[/red]")
                raise typer.Exit(code=1)
            except FileNotFoundError:
                console.print("    [red]✗[/red] rsync not found")
                raise typer.Exit(code=1)

        console.print()

    # Generate restore config
    if restore_entries:
        restore_config_path = archive_path / f"restore-{version}.yml"

        # Use env variables for configurable restore
        restore_sync = []
        for entry in restore_entries:
            target = entry["target"]
            img_type = entry.get("image_type", "unknown")

            # Split registry from path: registry/path -> path
            # target format: cr.noroutine.me/library/debian:version
            if "/" in target:
                # Remove registry (first part before /)
                parts = target.split("/", 1)
                image_path = parts[1] if len(parts) >= 2 else target
            else:
                image_path = target

            # Generate restore target based on image type
            if img_type == "upstream":
                # Upstream images: preserve original path (library/debian, prometheus/prometheus, etc.)
                # Restore to: {{ env "TARGET_REGISTRY" }}/library/debian:version
                restore_target = '{{ env "TARGET_REGISTRY" }}/' + image_path
            else:
                # Component/built images: use TARGET_NAMESPACE
                # Original: infra-dev/postgres:version
                # Extract just image name and tag (skip original namespace)
                if "/" in image_path:
                    path_parts = image_path.split("/", 1)
                    if len(path_parts) >= 2:
                        # Skip namespace, keep image:tag
                        image_name_tag = path_parts[1]
                    else:
                        image_name_tag = path_parts[0]
                else:
                    image_name_tag = image_path

                # Restore to: {{ env "TARGET_REGISTRY" }}/{{ env "TARGET_NAMESPACE" }}/postgres:version
                restore_target = '{{ env "TARGET_REGISTRY" }}/{{ env "TARGET_NAMESPACE" }}/' + image_name_tag

            restore_sync.append({
                "source": entry["source"],
                "target": restore_target,
                "type": entry["type"],
            })

        with open(restore_config_path, 'w') as f:
            f.write("# Infrastructure Image Restore Configuration\n")
            f.write("# Use environment variables to configure target registry and namespace\n")
            f.write("#\n")
            f.write("# Example:\n")
            f.write(f"#   export TARGET_REGISTRY={target_registry}\n")
            f.write(f"#   export TARGET_NAMESPACE={namespace}\n")
            f.write("#   regsync once -c restore-{version}.yml\n")
            f.write("#\n")
            f.write("# Or restore to different registry:\n")
            f.write("#   export TARGET_REGISTRY=my-registry.example.com\n")
            f.write("#   export TARGET_NAMESPACE=backup\n")
            f.write(f"#   regsync once -c restore-{version}.yml\n")
            f.write("\n")
            yaml.dump({"sync": restore_sync}, f, default_flow_style=False)

        console.print(f"[green]✓[/green] Generated restore config: {restore_config_path}")
        console.print(f"[dim]  Use: regsync once -c {restore_config_path}[/dim]")

        # Generate README.md
        from datetime import datetime

        # Count by type
        type_counts = {}
        for entry in restore_entries:
            img_type = entry.get("image_type", "unknown")
            type_counts[img_type] = type_counts.get(img_type, 0) + 1

        readme_content = f"""# Infrastructure Image Archive

**Version:** `{version}`
**Mode:** `{mode.upper()}`
**Registry:** `{target_registry}`
**Namespace:** `{namespace}`
**Created:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}

## Archive Contents

Total images: **{len(restore_entries)}**

"""

        if type_counts:
            readme_content += "### By Type\n\n"
            for img_type, count in sorted(type_counts.items()):
                readme_content += f"- **{img_type}**: {count} images\n"
            readme_content += "\n"

        readme_content += f"""## How to Restore

### Prerequisites

1. Install regclient tools:
   ```bash
   # macOS
   brew install regclient

   # Linux
   curl -L https://github.com/regclient/regclient/releases/latest/download/regsync-linux-amd64 \\
     -o /usr/local/bin/regsync
   chmod +x /usr/local/bin/regsync
   ```

2. Set up Docker credentials:
   ```bash
   # Login to target registry
   docker login {target_registry}
   ```

### Understanding Image Types

This archive contains different types of images that restore to different paths:

- **Upstream images**: Original third-party images (e.g., `debian`, `postgres`)
  - Restore to their original registry paths: `library/debian`, `prometheus/prometheus`, etc.
  - Use `TARGET_REGISTRY` only (no namespace override)

- **Component/Built images**: Infrastructure-specific images (e.g., custom builds)
  - Restore to versioned namespace: `{{{{ env "TARGET_NAMESPACE" }}}}/image:{version}`
  - Use both `TARGET_REGISTRY` and `TARGET_NAMESPACE`

### Restore All Images (Original Registry)

Set environment variables and run the restore config:

```bash
export TARGET_REGISTRY={target_registry}
export TARGET_NAMESPACE={namespace}
regsync once -c restore-{version}.yml
```

This will:
- Restore **upstream images** to their original paths (e.g., `library/debian`, `prometheus/prometheus`)
- Restore **component/built images** to the specified namespace
- Preserve all architectures and layers
- Resume from where it left off if interrupted

### Restore to Different Registry

You can restore to any registry by changing the environment variables:

```bash
export TARGET_REGISTRY=my-registry.example.com
export TARGET_NAMESPACE=backup
regsync once -c restore-{version}.yml
```

The restore config uses environment variables, allowing you to restore the same archive to multiple registries.

### Restore Specific Images

Edit `restore-{version}.yml` and comment out images you don't need:

```yaml
sync:
  # - source: ocidir://cr.noroutine.me-postgres-17.2-multiarch:17.2
  #   target: {target_registry}/{namespace}/postgres:{version}
  #   type: image
  - source: ocidir://cr.noroutine.me-redis-7.4-multiarch:7.4
    target: {target_registry}/{namespace}/redis:{version}
    type: image
```

### Verify Restore

Check that images are in the registry:

```bash
# Using regctl
regctl image manifest {target_registry}/{namespace}/postgres:{version}

# Using docker
docker pull {target_registry}/{namespace}/postgres:{version}
```

## Archive Structure

Each directory is an OCI layout containing a multi-arch image:

```
"""

        # Show some example directories
        example_dirs = []
        for entry in restore_entries[:5]:
            if "source" in entry:
                # Extract directory name from ocidir://path:tag
                oci_path = entry["source"].replace("ocidir://", "").split(":")[0]
                example_dirs.append(oci_path)

        for dir_name in example_dirs:
            readme_content += f"{dir_name}/\n"

        if len(restore_entries) > 5:
            readme_content += f"... and {len(restore_entries) - 5} more\n"

        readme_content += f"""
```

Each directory contains:
- `index.json` - OCI index
- `oci-layout` - OCI layout version
- `blobs/` - Image layers and manifests

## Storage Location

"""

        if upload:
            readme_content += f"""This archive has been uploaded to:

```
{storage_host}:{storage_path}/{version}/images
```

To download:

```bash
rsync -av {storage_host}:{storage_path}/{version}/images/ ./
```
"""
        else:
            readme_content += """This archive is local only and has not been uploaded to storage.
"""

        readme_content += f"""
## Notes

- **Mode: {mode.upper()}**
"""

        if mode == "upstream":
            readme_content += """  - Contains only upstream images from regsync.yml
  - Fast restore (no custom builds needed)
  - Suitable for quick registry recovery
"""
        else:
            readme_content += """  - Contains upstream + retagged components + built images
  - Complete disaster recovery archive
  - Large size but fully self-contained
"""

        readme_content += f"""
- Images are stored in OCI layout format (no tar/compression)
- Multi-architecture images preserved
- Generated by `infra archive-images` command

## Generated Files

- `restore-{version}.yml` - Regsync config for restoration
- `README.md` - This file

---

*Generated by infra-setup CLI v0.1.0*
"""

        readme_path = archive_path / "README.md"
        readme_path.write_text(readme_content)

        console.print(f"[green]✓[/green] Generated README: {readme_path}")

        # Upload restore config and README to storage
        if upload:
            console.print(f"\n[cyan]→[/cyan] Uploading restore config and README to storage...")
            storage_dest = f"{storage_host}:{storage_path}/{version}/images"

            try:
                subprocess.run(
                    [
                        "rsync", "-av", "-e", "ssh -o StrictHostKeyChecking=accept-new",
                        "--rsync-path", f"sudo mkdir -p {storage_path}/{version}/images && sudo rsync",
                        str(restore_config_path),
                        str(readme_path),
                        storage_dest + "/",
                    ],
                    check=True,
                    capture_output=True,
                    text=True,
                )
                console.print(f"  [green]✓[/green] Uploaded restore-{version}.yml and README.md")
            except subprocess.CalledProcessError as e:
                console.print(f"  [red]✗[/red] Upload failed: {e.stderr[:200]}")
                raise typer.Exit(code=1)
            except FileNotFoundError:
                console.print("  [red]✗[/red] rsync not found")
                raise typer.Exit(code=1)

        console.print()

    console.print(f"[bold green]✓ Archive complete:[/bold green]")
    console.print(f"  Archived: {total_archived} images")
    console.print(f"  Batches: {total_batches}")
    console.print(f"  Location: {archive_path}")

    if upload:
        console.print(f"  Storage: {storage_host}:{storage_path}/{version}/images")
        console.print(f"  [dim]Includes: restore-{version}.yml and README.md[/dim]")
        if cleanup_after_upload:
            console.print(f"  [dim]Cleaned up local archives after upload (saved disk space)[/dim]")


@app.command()
def upgrade(
    upstream_repo: str = typer.Option("noroutine/upstream", "--repo", "-r", help="Upstream GitHub repo (owner/repo)"),
    regsync_config: str = typer.Option("regsync.yml", "--regsync", help="Path to regsync.yml"),
    variables_file: str = typer.Option("variables.yml", "--variables", "-v", help="Path to variables.yml"),
    target_registry: str = typer.Option("cr.noroutine.me", "--registry", help="Target registry"),
    apply: bool = typer.Option(False, "--apply", help="Apply upgrades to variables.yml"),
    skip_prerelease: bool = typer.Option(True, "--skip-prerelease/--include-prerelease", help="Skip pre-release versions (dev, alpha, beta, rc)"),
    github_token: Optional[str] = typer.Option(None, "--token", help="GitHub API token (or use GITHUB_TOKEN env var)", envvar="GITHUB_TOKEN"),
):
    """Check Dependabot PRs and suggest version upgrades for variables.yml."""
    import yaml
    from pathlib import Path
    from ruamel.yaml import YAML

    console.print(Panel.fit("🚀  Checking for Upgrades", style="bold blue"))

    # Fetch Dependabot PRs
    console.print(f"[dim]Fetching Dependabot PRs from {upstream_repo}...[/dim]")
    try:
        prs = get_dependabot_prs(upstream_repo, state="open", github_token=github_token)
        console.print(f"[dim]Found {len(prs)} Dependabot PRs[/dim]\n")
    except Exception as e:
        console.print(f"[red]✗ Failed to fetch PRs: {e}[/red]")
        raise typer.Exit(code=1)

    if not prs:
        console.print("[green]✓ No Dependabot PRs found - everything is up to date![/green]")
        return

    # Parse regsync config to build image -> variable mapping
    console.print(f"[dim]Parsing {regsync_config} to map images to variables...[/dim]")
    try:
        variables = load_variables(variables_file)

        # Build mapping: normalized_image_name -> (variable_name, current_value, full_image_path)
        image_to_variable = {}

        # Load raw regsync.yml (not expanded) to extract variable names
        with open(regsync_config) as f:
            regsync_data = yaml.safe_load(f)

        # Extract variable references from sync entries
        # Pattern: {{ env "VAR_NAME" }}
        for entry in regsync_data.get("sync", []):
            source = entry.get("source", "")
            # Find variables used in this source
            var_matches = re.findall(r'\{\{\s*env\s+"([^"]+)"\s*\}\}', source)

            # Extract image reference from source (before :version)
            if ":" not in source:
                continue  # No version template, skip

            image_ref = source.split(":")[0]

            # Check if image_ref has a registry prefix (domain.tld/)
            # Registry domains contain dots and come before the first slash
            if "/" in image_ref:
                first_part = image_ref.split("/")[0]
                if "." in first_part:
                    # Has registry prefix (e.g., docker.elastic.co/logstash/logstash)
                    # Remove it: docker.elastic.co/logstash/logstash -> logstash/logstash
                    image_path = "/".join(image_ref.split("/")[1:])
                else:
                    # No registry, keep full path (e.g., sonatype/nexus3 -> sonatype/nexus3)
                    image_path = image_ref
            else:
                # Simple image without slash (e.g., postgres -> postgres)
                image_path = image_ref

            normalized = normalize_image_name(image_path)

            # Find the version variable
            # Prefer variables with VERSION in name, but accept any variable
            version_var = None
            if var_matches:
                # First try to find one with VERSION in name
                for var in var_matches:
                    if "VERSION" in var:
                        version_var = var
                        break
                # If not found, use the last variable (most likely to be the version)
                if not version_var:
                    version_var = var_matches[-1]

            if version_var:
                image_to_variable[normalized] = (
                    version_var,
                    variables.get(version_var, "?"),
                    image_path,
                    image_ref  # Store full source with registry
                )

        console.print(f"[dim]Mapped {len(image_to_variable)} images to variables[/dim]\n")

    except Exception as e:
        console.print(f"[red]✗ Failed to parse regsync config: {e}[/red]")
        raise typer.Exit(code=1)

    # Helper function to detect pre-release versions
    def is_prerelease(version: str) -> bool:
        """Check if version string contains pre-release identifiers."""
        version_lower = version.lower()
        prerelease_markers = [
            '.dev', '-dev',
            '.alpha', '-alpha',
            '.beta', '-beta',
            '.rc', '-rc',
            'snapshot',
        ]
        return any(marker in version_lower for marker in prerelease_markers)

    # Helper function to generate registry URLs
    def get_registry_url(source: str, image_path: str) -> str | None:
        """Generate tags page URL for the image registry."""
        source_lower = source.lower()

        # Quay.io
        if source_lower.startswith("quay.io/"):
            # quay.io/prometheus/prometheus -> https://quay.io/repository/prometheus/prometheus?tab=tags
            return f"https://quay.io/repository/{image_path}?tab=tags"

        # Docker Elastic
        elif source_lower.startswith("docker.elastic.co/"):
            # docker.elastic.co/logstash/logstash -> https://www.docker.elastic.co/r/logstash/logstash
            return f"https://www.docker.elastic.co/r/{image_path}"

        # Docker Hub (no registry prefix or docker.io)
        elif not "." in source.split("/")[0] or source_lower.startswith("docker.io/"):
            # Check if it's an official image (no namespace) or has namespace
            if "/" in image_path:
                # User/org image: haproxytech/haproxy-alpine
                return f"https://hub.docker.com/r/{image_path}/tags"
            else:
                # Official image: postgres, nginx, etc.
                return f"https://hub.docker.com/_/{image_path}/tags"

        # Unknown/custom registry
        return None

    # Parse PRs and find matching upgrades
    upgrades = []
    skipped_prerelease = []

    for pr in prs:
        title = pr.get("title", "")
        pr_number = pr.get("number")
        pr_url = pr.get("html_url")

        image, old_version, new_version = parse_dependabot_title(title)

        if not image or not new_version:
            continue

        normalized_image = normalize_image_name(image)

        # Try to find matching variable
        if normalized_image in image_to_variable:
            var_name, current_value, full_image, source_with_registry = image_to_variable[normalized_image]

            # Skip pre-release versions if requested
            if skip_prerelease and is_prerelease(new_version):
                skipped_prerelease.append({
                    "pr_number": pr_number,
                    "image": full_image,
                    "variable": var_name,
                    "new": new_version,
                })
                continue

            upgrades.append({
                "pr_number": pr_number,
                "pr_url": pr_url,
                "image": full_image,
                "source": source_with_registry,
                "variable": var_name,
                "current": current_value,
                "new": new_version,
                "title": title,
            })

    # Show skipped pre-release versions
    if skipped_prerelease:
        console.print(f"\n[dim]Skipped {len(skipped_prerelease)} pre-release version(s):[/dim]")
        for skipped in skipped_prerelease:
            console.print(f"  [dim]#{skipped['pr_number']} {skipped['image']}: {skipped['new']} (pre-release)[/dim]")

    if not upgrades:
        console.print("[yellow]⚠ No stable upgrades found in Dependabot PRs[/yellow]")
        if skipped_prerelease:
            console.print("[dim]All matched PRs were pre-release versions (use --include-prerelease to see them)[/dim]")
        else:
            console.print("[dim]PRs might not match any images in regsync.yml[/dim]")
        return

    # Show upgrades in table
    table = Table(show_header=True, header_style="bold cyan", title="Available Upgrades")
    table.add_column("PR", style="dim", width=6)
    table.add_column("Image", style="yellow")
    table.add_column("Variable", style="cyan")
    table.add_column("Current")
    table.add_column("", justify="center", width=3)
    table.add_column("New")

    upgrades_needed = 0
    already_current = 0

    for upgrade in upgrades:
        is_current = upgrade['current'] == upgrade['new']

        if is_current:
            # Already up to date
            current_style = "green"
            arrow = "="
            new_style = "green"
            already_current += 1
        else:
            # Needs upgrade
            current_style = "red"
            arrow = "→"
            new_style = "green"
            upgrades_needed += 1

        # Generate registry URL for image
        registry_url = get_registry_url(upgrade['source'], upgrade['image'])
        if registry_url:
            image_display = f"[link={registry_url}]{upgrade['image']}[/link]"
        else:
            image_display = upgrade['image']

        table.add_row(
            f"[link={upgrade['pr_url']}]#{upgrade['pr_number']}[/link]",
            image_display,
            upgrade['variable'],
            f"[{current_style}]{upgrade['current']}[/{current_style}]",
            arrow,
            f"[{new_style}]{upgrade['new']}[/{new_style}]",
        )

    console.print(table)
    console.print(f"\n[bold]Total:[/bold] {len(upgrades)} ({upgrades_needed} to upgrade, {already_current} already current)")

    # Apply upgrades if requested
    if apply:
        console.print(f"\n[bold cyan]Applying upgrades to {variables_file}...[/bold cyan]")

        # Load variables.yml with ruamel.yaml to preserve comments
        ryaml = YAML()
        ryaml.preserve_quotes = True
        ryaml.width = 4096  # Prevent line wrapping

        with open(variables_file) as f:
            variables_data = ryaml.load(f)

        applied = 0
        for upgrade in upgrades:
            var_name = upgrade['variable']
            new_value = upgrade['new']

            if var_name in variables_data.get('variables', {}):
                old_value = variables_data['variables'][var_name]
                variables_data['variables'][var_name] = new_value
                console.print(f"  [green]✓[/green] {var_name}: {old_value} → {new_value}")
                applied += 1
            else:
                console.print(f"  [yellow]⚠[/yellow] {var_name} not found in variables")

        # Write back to file with preserved comments and formatting
        if applied > 0:
            with open(variables_file, 'w') as f:
                ryaml.dump(variables_data, f)

            console.print(f"\n[bold green]✓ Applied {applied} upgrades to {variables_file}[/bold green]")
            console.print(f"[dim]Review changes with: git diff {variables_file}[/dim]")
        else:
            console.print(f"\n[yellow]No upgrades applied[/yellow]")
    else:
        console.print(f"\n[dim]Run with --apply to update {variables_file}[/dim]")


@app.command()
def analyze_charts(
    charts_dir: str = typer.Option("docker/infra-charts/charts", "--charts-dir", help="Path to charts directory"),
    show_dependencies: bool = typer.Option(False, "--show-dependencies", "-d", help="Show detailed dependencies per chart"),
):
    """Analyze imported Helm charts for versions and dependencies."""
    import tarfile
    from pathlib import Path
    import yaml
    from packaging import version

    console.print(Panel.fit("📊 Analyzing Helm Charts", style="bold blue"))

    charts_path = Path(charts_dir)
    if not charts_path.exists():
        console.print(f"[red]✗ Charts directory not found: {charts_dir}[/red]")
        raise typer.Exit(code=1)

    # Find all chart namespaces (subdirectories)
    chart_info = []

    for namespace_dir in sorted(charts_path.iterdir()):
        if not namespace_dir.is_dir():
            continue

        # Find all .tgz files in this namespace
        tgz_files = list(namespace_dir.glob("*.tgz"))
        if not tgz_files:
            continue

        # Find the latest version by parsing version from filename
        # Format: chartname-X.Y.Z.tgz
        latest_chart = None
        latest_version = None

        for tgz_file in tgz_files:
            # Extract version from filename: chartname-1.2.3.tgz
            filename = tgz_file.stem  # Remove .tgz
            parts = filename.rsplit("-", 1)
            if len(parts) == 2:
                try:
                    ver = version.parse(parts[1])
                    if latest_version is None or ver > latest_version:
                        latest_version = ver
                        latest_chart = tgz_file
                except Exception:
                    continue

        if not latest_chart:
            continue

        # Extract Chart.yaml from the tarball
        try:
            with tarfile.open(latest_chart, "r:gz") as tar:
                # Chart.yaml is typically at chartname/Chart.yaml
                chart_yaml_path = None
                for member in tar.getmembers():
                    if member.name.endswith("/Chart.yaml") or member.name == "Chart.yaml":
                        chart_yaml_path = member
                        break

                if not chart_yaml_path:
                    console.print(f"[yellow]⚠ No Chart.yaml found in {latest_chart.name}[/yellow]")
                    continue

                # Extract and parse Chart.yaml
                chart_file = tar.extractfile(chart_yaml_path)
                if not chart_file:
                    console.print(f"[yellow]⚠ Could not extract Chart.yaml from {latest_chart.name}[/yellow]")
                    continue

                chart_data = yaml.safe_load(chart_file)

                chart_name = chart_data.get("name", namespace_dir.name)
                chart_version = chart_data.get("version", "?")
                app_version = chart_data.get("appVersion", "?")
                dependencies = chart_data.get("dependencies", [])

                chart_info.append({
                    "namespace": namespace_dir.name,
                    "name": chart_name,
                    "chart_version": str(chart_version),
                    "app_version": str(app_version),
                    "dependencies": dependencies,
                    "dep_count": len(dependencies),
                })

        except Exception as e:
            console.print(f"[yellow]⚠ Failed to parse {latest_chart.name}: {e}[/yellow]")
            continue

    if not chart_info:
        console.print("[yellow]No charts found to analyze[/yellow]")
        return

    # Show summary table
    table = Table(show_header=True, header_style="bold cyan", title=f"Chart Analysis Summary ({len(chart_info)} charts)")
    table.add_column("Chart", style="yellow")
    table.add_column("Chart Version", style="cyan")
    table.add_column("App Version", style="green")
    table.add_column("Dependencies", justify="right", style="magenta")

    for info in sorted(chart_info, key=lambda x: x['name']):
        dep_display = str(info['dep_count']) if info['dep_count'] > 0 else "[dim]0[/dim]"
        table.add_row(
            info['name'],
            info['chart_version'],
            info['app_version'],
            dep_display,
        )

    console.print(table)

    # Show detailed dependencies if requested
    if show_dependencies:
        charts_with_deps = [c for c in chart_info if c['dep_count'] > 0]
        if charts_with_deps:
            console.print(f"\n[bold cyan]Dependency Details ({len(charts_with_deps)} charts with dependencies):[/bold cyan]\n")

            for info in sorted(charts_with_deps, key=lambda x: x['name']):
                console.print(f"[bold yellow]{info['name']}[/bold yellow] [dim]({info['chart_version']})[/dim]")

                for dep in info['dependencies']:
                    dep_name = dep.get('name', '?')
                    dep_version = dep.get('version', '?')
                    dep_repo = dep.get('repository', '')

                    # Format repository URL nicely
                    if dep_repo.startswith('http'):
                        repo_display = f"[dim]{dep_repo}[/dim]"
                    elif dep_repo.startswith('oci://'):
                        repo_display = f"[dim]{dep_repo}[/dim]"
                    elif dep_repo.startswith('file://') or dep_repo.startswith('../'):
                        repo_display = "[dim]local[/dim]"
                    else:
                        repo_display = f"[dim]{dep_repo}[/dim]" if dep_repo else ""

                    console.print(f"  [cyan]•[/cyan] {dep_name} [green]{dep_version}[/green] {repo_display}")

                console.print()
        else:
            console.print("\n[dim]No charts with dependencies found[/dim]")
    else:
        charts_with_deps_count = sum(1 for c in chart_info if c['dep_count'] > 0)
        if charts_with_deps_count > 0:
            console.print(f"\n[dim]Use --show-dependencies to see dependency details for {charts_with_deps_count} charts[/dim]")


if __name__ == "__main__":
    app()

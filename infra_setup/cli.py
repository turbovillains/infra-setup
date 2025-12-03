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

app = typer.Typer(
    name="infra",
    help="Infrastructure image management and artifact generation",
    add_completion=False,
    invoke_without_command=True,
)
console = Console()


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


if __name__ == "__main__":
    app()

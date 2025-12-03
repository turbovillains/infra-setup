"""CLI for infrastructure setup operations."""

import json
import os
import subprocess
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

app = typer.Typer(
    name="infra",
    help="Infrastructure image management and artifact generation",
    add_completion=False,
)
console = Console()


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


if __name__ == "__main__":
    app()

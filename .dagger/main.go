package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"text/template"

	"dagger/infra-setup/infra"
	"dagger/infra-setup/internal/dagger"

	"github.com/google/go-containerregistry/pkg/authn"
	"github.com/google/go-containerregistry/pkg/crane"
	"gopkg.in/yaml.v3"
)

type InfraSetup struct {
	// Source directory (set by New constructor, appears in dagger functions as getter)
	Source *dagger.Directory
	// Variables file path (set by New constructor, appears in dagger functions as getter)
	VariablesFile string
	// Target registry (set by New constructor, appears in dagger functions as getter)
	TargetRegistry string
	// keep as Secret; only decode right before using
	DockerCfg *dagger.Secret
	// SSH private key for uploading to storage
	SshPrivateKey *dagger.Secret

	// cache
	keychain authn.Keychain
}

func New(
	// +defaultPath="."
	// +ignore=["gitlab", "dist", "build", "archive", ".git"]
	source *dagger.Directory,
	// +optional
	// +default="variables.yml"
	variablesFile string,
	// Target registry (default: cr.noroutine.me, use DOCKER_HUB var in GitLab)
	// +optional
	// +default="cr.noroutine.me"
	targetRegistry string,
) *InfraSetup {
	return &InfraSetup{
		Source:         source,
		VariablesFile:  variablesFile,
		TargetRegistry: targetRegistry,
	}
}

type Variables struct {
	Variables map[string]string `yaml:"variables"`
}

type ImageEntry struct {
	Source string
	Target string
}

type RegsyncConfig struct {
	Sync []struct {
		Source string `yaml:"source"`
		Target string `yaml:"target"`
		Type   string `yaml:"type"`
	} `yaml:"sync"`
}

// WithDockerCfg stores the secret on the object so it can be reused.
func (m *InfraSetup) WithDockerCfg(dockerCfg *dagger.Secret) *InfraSetup {
	// return a *new* configured object if you prefer immutability patterns
	m.DockerCfg = dockerCfg
	return m
}

// WithSshPrivateKey stores the SSH private key secret on the object so it can be reused.
func (m *InfraSetup) WithSshPrivateKey(sshPrivateKey *dagger.Secret) *InfraSetup {
	m.SshPrivateKey = sshPrivateKey
	return m
}

// ensureKeychain populates & caches the in-memory keychain once.
func (m *InfraSetup) ensureKeychain(ctx context.Context) (authn.Keychain, error) {
	if m.keychain != nil {
		return m.keychain, nil
	}
	if m.DockerCfg == nil {
		return nil, fmt.Errorf("dockerCfg is required; call WithDockerCfg first")
	}
	b64, err := m.DockerCfg.Plaintext(ctx) // <-- one trace total
	if err != nil {
		return nil, fmt.Errorf("read dockerCfg secret: %w", err)
	}
	kc, err := infra.KeychainFromDockerCfgBase64(b64)
	if err != nil {
		return nil, err
	}
	m.keychain = kc
	return m.keychain, nil
}

// TestPaths helps debug file paths in module
func (m *InfraSetup) TestPaths(
	ctx context.Context,
) (string, error) {
	var output strings.Builder

	// 1. Module source (from dagger.json "source" field)
	output.WriteString("=== 1. Module Source (dag.CurrentModule().Source()) ===\n")
	entries, err := dag.CurrentModule().Source().Entries(ctx)
	if err != nil {
		output.WriteString(fmt.Sprintf("ERROR: %v\n", err))
	} else {
		for _, entry := range entries {
			output.WriteString(fmt.Sprintf("  %s\n", entry))
		}
	}
	output.WriteString("\n")

	// 2. Constructor Source (m.source from New())
	output.WriteString("=== 2. Constructor Source (m.source from New()) ===\n")
	if m.Source == nil {
		output.WriteString("  m.Source is nil\n")
	} else {
		entries, err := m.Source.Entries(ctx)
		if err != nil {
			output.WriteString(fmt.Sprintf("ERROR: %v\n", err))
		} else {
			for i, entry := range entries {
				output.WriteString(fmt.Sprintf("  %s\n", entry))
				if i > 20 {
					output.WriteString(fmt.Sprintf("  ... (%d more entries)\n", len(entries)-i-1))
					break
				}
			}
		}
	}
	output.WriteString("\n")

	// 3. Try reading variables.yml from different sources
	output.WriteString("=== 3. Reading variables.yml ===\n")

	output.WriteString("From Module Source:\n")
	file := dag.CurrentModule().Source().File("variables.yml")
	content, err := file.Contents(ctx)
	if err != nil {
		output.WriteString(fmt.Sprintf("  ERROR: %v\n", err))
	} else {
		output.WriteString(fmt.Sprintf("  SUCCESS: %d bytes\n", len(content)))
	}

	if m.Source != nil {
		output.WriteString("From Constructor Source:\n")
		file := m.Source.File("variables.yml")
		content, err := file.Contents(ctx)
		if err != nil {
			output.WriteString(fmt.Sprintf("  ERROR: %v\n", err))
		} else {
			output.WriteString(fmt.Sprintf("  SUCCESS: %d bytes\n", len(content)))
		}
	}

	return output.String(), nil
}

// ListVariables shows all variables from variables.yml
func (m *InfraSetup) ListVariables(
	ctx context.Context,
) (string, error) {
	vars, err := m.loadVariables(ctx, m.Source.File(m.VariablesFile))
	if err != nil {
		return "", err
	}

	var output strings.Builder
	output.WriteString("Variables:\n")
	for key, value := range vars.Variables {
		output.WriteString(fmt.Sprintf("  %s=%s\n", key, value))
	}

	return output.String(), nil
}

// ListImages lists all images that would be imported (dry-run)
func (m *InfraSetup) ListImages(
	ctx context.Context,
	// Pattern to match image names (empty for all images)
	// +optional
	pattern string,
) (string, error) {
	imageEntries, err := m.getImageEntries(ctx)
	if err != nil {
		return "", err
	}

	var results strings.Builder
	matched := 0

	for _, entry := range imageEntries {
		// If pattern is empty or matches
		if pattern == "" || strings.Contains(entry.Source, pattern) {
			results.WriteString(fmt.Sprintf("%s -> %s\n", entry.Source, entry.Target))
			matched++
		}
	}

	results.WriteString(fmt.Sprintf("\nTotal: %d image(s)\n", matched))
	return results.String(), nil
}

// ImportImages imports images, optionally filtered by pattern
func (m *InfraSetup) ImportImages(
	ctx context.Context,
	// Pattern to match image names (empty for all images)
	// +optional
	pattern string,
) (string, error) {
	imageEntries, err := m.getImageEntries(ctx)
	if err != nil {
		return "", err
	}

	var results strings.Builder
	matched := 0

	for _, entry := range imageEntries {
		// If pattern is empty or matches
		if pattern == "" || strings.Contains(entry.Source, pattern) {
			if _, err := m.pullAndPush(ctx, entry.Source, entry.Target); err != nil {
				return "", fmt.Errorf("failed to import %s: %w", entry.Source, err)
			}

			results.WriteString(fmt.Sprintf("✓ %s -> %s\n", entry.Source, entry.Target))
			matched++
		}
	}

	if matched == 0 {
		if pattern != "" {
			return fmt.Sprintf("No images matched pattern: %s\n", pattern), nil
		}
		return "No images found\n", nil
	}

	results.WriteString(fmt.Sprintf("\nImported %d image(s)\n", matched))
	return results.String(), nil
}

// ArchiveImagesForExport creates compressed tarballs of images from the target registry, optionally filtered by pattern and platform.
// Images must be imported first (use import-images). Archives are pulled from target registry.
// Returns a directory containing the archives. Use .export() to save to host.
func (m *InfraSetup) ArchiveImagesForExport(
	ctx context.Context,
	// Pattern to match image names (empty for all images)
	// +optional
	pattern string,
	// Platform to export (e.g., "linux/amd64", "linux/arm64"). Default: multiarch (all platforms)
	// +optional
	platform string,
) (*dagger.Directory, error) {
	// Default to "all" (multiarch) if platform not specified
	if platform == "" {
		platform = "all"
	}

	imageEntries, err := m.getImageEntries(ctx)
	if err != nil {
		return nil, err
	}

	// Start with empty directory
	outputDir := dag.Directory()

	for _, entry := range imageEntries {
		// If pattern is empty or matches source
		if pattern == "" || strings.Contains(entry.Source, pattern) {
			dir, archiveName, err := m.archiveImage(ctx, entry.Target, platform)
			if err != nil {
				return nil, fmt.Errorf("failed to archive %s (from %s): %w", entry.Target, entry.Source, err)
			}

			// Get the file from the directory and add to output
			archiveFile := dir.File(archiveName)
			outputDir = outputDir.WithFile(archiveName, archiveFile)
		}
	}

	return outputDir, nil
}

// ArchiveImagesToStorage creates compressed tarballs of images and uploads them directly to storage.
// Images must be imported first (use import-images). Archives are pulled from target registry.
// Uploads to oleksii@mgmt02-vm-core01.noroutine.me:/mnt/data/infra/{infraBucket}/images/
func (m *InfraSetup) ArchiveImagesToStorage(
	ctx context.Context,
	// Infrastructure bucket name (e.g., version or identifier)
	infraBucket string,
	// Pattern to match image names (empty for all images)
	// +optional
	pattern string,
	// Platform to export (e.g., "linux/amd64", "linux/arm64"). Default: multiarch (all platforms)
	// +optional
	platform string,
) (string, error) {
	if m.SshPrivateKey == nil {
		return "", fmt.Errorf("sshPrivateKey is required; call WithSshPrivateKey first")
	}

	// Default to "all" (multiarch) if platform not specified
	if platform == "" {
		platform = "all"
	}

	imageEntries, err := m.getImageEntries(ctx)
	if err != nil {
		return "", err
	}
	matched := 0

	for _, entry := range imageEntries {
		// If pattern is empty or matches source
		if pattern == "" || strings.Contains(entry.Source, pattern) {
			dir, archiveName, err := m.archiveImage(ctx, entry.Target, platform)
			if err != nil {
				return "", fmt.Errorf("failed to archive %s (from %s): %w", entry.Target, entry.Source, err)
			}

			// Upload this archive to storage
			if err := m.uploadArchiveToStorage(ctx, dir, archiveName, infraBucket); err != nil {
				return "", fmt.Errorf("failed to upload %s: %w", archiveName, err)
			}

			matched++
		}
	}

	if matched == 0 {
		msg := "No images found"
		if pattern != "" {
			msg = fmt.Sprintf("No images matched pattern: %s", pattern)
		}
		return msg, nil
	}

	return fmt.Sprintf("Successfully archived and uploaded %d image(s) to storage (bucket: %s)\n", matched, infraBucket), nil
}

// uploadArchiveToStorage uploads a single archive to remote storage using rsync
func (m *InfraSetup) uploadArchiveToStorage(ctx context.Context, archiveDir *dagger.Directory, archiveName string, infraBucket string) error {
	// Create a container with rsync and ssh
	container := dag.Container().
		From("alpine:latest").
		WithExec([]string{"apk", "add", "--no-cache", "rsync", "openssh-client", "coreutils"})

	// Set up SSH key (base64-encoded secret, needs to be decoded)
	container = container.
		WithMountedSecret("/tmp/ssh-key-b64", m.SshPrivateKey).
		WithExec([]string{"sh", "-c", "mkdir -p /root/.ssh && base64 -d /tmp/ssh-key-b64 > /root/.ssh/id_rsa && chmod 600 /root/.ssh/id_rsa"})

	// Get the archive file from the directory
	archiveFile := archiveDir.File(archiveName)

	// Mount the archive file
	container = container.
		WithFile("/tmp/"+archiveName, archiveFile)

	// Upload using rsync (following the pattern from 02_lib.sh)
	targetPath := fmt.Sprintf("oleksii@mgmt02-vm-core01.noroutine.me:/mnt/data/infra/%s/images/%s", infraBucket, archiveName)
	rsyncCommand := fmt.Sprintf(
		"rsync -e 'ssh -o StrictHostKeyChecking=no' --rsync-path='sudo mkdir -p /mnt/data/infra/%s/images && sudo rsync' /tmp/%s %s && rm -f /tmp/%s",
		infraBucket, archiveName, targetPath, archiveName,
	)

	container = container.
		WithExec([]string{"sh", "-c", rsyncCommand})

	// Force execution
	_, err := container.Stdout(ctx)
	if err != nil {
		return err
	}

	fmt.Fprintf(os.Stdout, "  Uploaded %s to storage (cleaned up)\n", archiveName)
	return nil
}

// archiveImage pulls a single image in OCI format and saves it as a compressed tarball
// Returns the directory containing the archive and the archive filename
func (m *InfraSetup) archiveImage(ctx context.Context, imageName string, platform string) (*dagger.Directory, string, error) {
	if m.DockerCfg == nil {
		return nil, "", fmt.Errorf("dockerCfg is required; call WithDockerCfg first")
	}

	// Generate archive filename: replace / and : with -
	archiveName := strings.ReplaceAll(imageName, "/", "-")
	archiveName = strings.ReplaceAll(archiveName, ":", "-")

	// Default to "all" (multiarch) if platform not specified
	if platform == "" {
		platform = "all"
	}

	// Add platform suffix (multiarch or specific platform)
	if platform == "all" {
		archiveName = archiveName + "-multiarch"
	} else {
		platformSuffix := strings.ReplaceAll(platform, "/", "-")
		archiveName = archiveName + "-" + platformSuffix
	}

	ociDir := archiveName
	archiveName = archiveName + ".tar.zst"

	// Create a container with crane and zstd
	container := dag.Container().
		From("alpine:latest").
		WithExec([]string{"apk", "add", "--no-cache", "crane", "zstd", "coreutils", "tar"})

	// Set up Docker config for authentication
	// The secret is base64-encoded, so we need to decode it first
	container = container.
		WithMountedSecret("/tmp/docker-config-b64", m.DockerCfg).
		WithExec([]string{"sh", "-c", "mkdir -p /root/.docker && base64 -d /tmp/docker-config-b64 > /root/.docker/config.json"})

	// Build crane pull command with OCI format and platform
	craneArgs := []string{"crane", "pull", "--format", "oci", "--platform", platform, imageName, "/tmp/" + ociDir}

	// Pull the image in OCI format (creates a directory)
	container = container.
		WithExec(craneArgs)

	// Tar the OCI directory and compress with zstd (using all cores with -T0)
	// Create output directory, tar the OCI dir, and compress it
	container = container.
		WithExec([]string{"sh", "-c", fmt.Sprintf(
			"mkdir -p /output && cd /tmp && tar -cf - %s | zstd -T0 -o /output/%s",
			ociDir, archiveName,
		)})

	// Export the compressed file
	return container.Directory("/output"), archiveName, nil
}

func (m *InfraSetup) loadVariables(ctx context.Context, file *dagger.File) (*Variables, error) {
	content, err := file.Contents(ctx)
	if err != nil {
		return nil, err
	}

	var vars Variables
	if err := yaml.Unmarshal([]byte(content), &vars); err != nil {
		return nil, err
	}

	return &vars, nil
}

// parseRegsyncConfig reads regsync.yml and returns parsed image entries
func (m *InfraSetup) parseRegsyncConfig(ctx context.Context) ([]ImageEntry, error) {
	// Read regsync.yml from source directory
	regsyncFile := m.Source.File("regsync.yml")
	content, err := regsyncFile.Contents(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to read regsync.yml: %w", err)
	}

	// Load variables for template expansion
	varsFile := m.Source.File(m.VariablesFile)
	vars, err := m.loadVariables(ctx, varsFile)
	if err != nil {
		return nil, fmt.Errorf("failed to load variables: %w", err)
	}

	// Create template function map with env function
	funcMap := template.FuncMap{
		"env": func(key string) string {
			// Check if it's TARGET_REGISTRY
			if key == "TARGET_REGISTRY" {
				return m.TargetRegistry
			}
			// Otherwise lookup in variables
			if val, ok := vars.Variables[key]; ok {
				return val
			}
			return ""
		},
	}

	// Parse YAML
	var config RegsyncConfig
	if err := yaml.Unmarshal([]byte(content), &config); err != nil {
		return nil, fmt.Errorf("failed to parse regsync.yml: %w", err)
	}

	// Process each sync entry
	var entries []ImageEntry
	for i, syncEntry := range config.Sync {
		// Only process image type entries
		if syncEntry.Type != "image" {
			continue
		}

		// Expand source template
		sourceTmpl, err := template.New(fmt.Sprintf("source-%d", i)).Funcs(funcMap).Parse(syncEntry.Source)
		if err != nil {
			return nil, fmt.Errorf("failed to parse source template for entry %d: %w", i, err)
		}
		var sourceBuf bytes.Buffer
		if err := sourceTmpl.Execute(&sourceBuf, nil); err != nil {
			return nil, fmt.Errorf("failed to execute source template for entry %d: %w", i, err)
		}
		source := sourceBuf.String()

		// Expand target template
		targetTmpl, err := template.New(fmt.Sprintf("target-%d", i)).Funcs(funcMap).Parse(syncEntry.Target)
		if err != nil {
			return nil, fmt.Errorf("failed to parse target template for entry %d: %w", i, err)
		}
		var targetBuf bytes.Buffer
		if err := targetTmpl.Execute(&targetBuf, nil); err != nil {
			return nil, fmt.Errorf("failed to execute target template for entry %d: %w", i, err)
		}
		target := targetBuf.String()

		entries = append(entries, ImageEntry{
			Source: source,
			Target: target,
		})
	}

	return entries, nil
}

// getImageEntries returns all image entries by reading and parsing regsync.yml
func (m *InfraSetup) getImageEntries(ctx context.Context) ([]ImageEntry, error) {
	return m.parseRegsyncConfig(ctx)
}

// pullAndPush pulls source image and pushes to destination using crane for multiarch support
func (m *InfraSetup) pullAndPush(ctx context.Context, source, destination string) (string, error) {
	kc, err := m.ensureKeychain(ctx)
	if err != nil {
		return "", err
	}

	// 2) Use crane with our keychain (no files, no progress)
	opts := []crane.Option{
		crane.WithContext(ctx),
		crane.WithAuthFromKeychain(kc),
	}

	if err := crane.Copy(source, destination, opts...); err != nil {
		return "", err
	}

	fmt.Fprintf(os.Stdout, "imported %s -> %s\n", source, destination)

	return fmt.Sprintf("%s -> %s\n", source, destination), nil
}

// GenerateArtifacts generates infra.json and Dockerfile for dependency tracking
func (m *InfraSetup) GenerateArtifacts(
	ctx context.Context,
	// Infrastructure version (e.g., "1.0.0", defaults to "dev")
	// +optional
	// +default="dev"
	infraVersion string,
) (*dagger.Directory, error) {
	imageEntries, err := m.getImageEntries(ctx)
	if err != nil {
		return nil, err
	}

	// Generate Dockerfile
	var dockerfile strings.Builder
	var upstreamImages []string

	for _, entry := range imageEntries {
		// Extract image name for comment
		parts := strings.SplitN(entry.Source, ":", 2)
		imageName := parts[0]

		dockerfile.WriteString(fmt.Sprintf("# %s\n", imageName))
		dockerfile.WriteString(fmt.Sprintf("FROM %s\n", entry.Source))
		dockerfile.WriteString(fmt.Sprintf("# %s\n\n", imageName))

		upstreamImages = append(upstreamImages, entry.Source)
	}

	// Generate infra.json
	infraJSON := map[string]interface{}{
		"version": infraVersion,
		"upstream": map[string]interface{}{
			"images": upstreamImages,
		},
	}

	jsonBytes, err := json.MarshalIndent(infraJSON, "", "  ")
	if err != nil {
		return nil, fmt.Errorf("marshaling infra.json: %w", err)
	}

	// Create directory with both files
	dir := dag.Directory().
		WithNewFile("Dockerfile", dockerfile.String()).
		WithNewFile("infra.json", string(jsonBytes))

	return dir, nil
}

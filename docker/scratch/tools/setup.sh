#!/bin/bash

# Docker style, used by most
ARCHX=$(uname -m | sed 's/aarch64/arm64/;s/x86_64/amd64/')

# Used by crane
ARCHY=$(uname -m | sed 's/aarch64/arm64/')

# Plane linux arch, used by goreleaser
ARCHZ=$(uname -m)

set -e

# Track failed installations
FAILED_TOOLS=()
LOCK_FILE="/tmp/tools_install.lock"

# Function to record failures
record_failure() {
  local tool=$1
  flock "$LOCK_FILE" bash -c "echo '$tool' >> /tmp/failed_tools.txt"
}

# Install functions for each tool
install_kubectl() {
  echo "Installing kubectl..."
  curl -sLo /usr/local/bin/kubectl "https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCHX}/kubectl" && chmod +x /usr/local/bin/kubectl || record_failure "kubectl"
}

install_jq() {
  echo "Installing jq..."
  # https://github.com/stedolan/jq/releases
  # Bootstrap problem: can't use jq to parse JSON for jq's version!
  # Solution: Use awk to parse the JSON response
  JQ_VERSION=$(curl -s "https://api.github.com/repos/jqlang/jq/releases/latest" | awk -F'"' '/"tag_name":/ {print $4}' || echo "jq-1.8.1")
  echo "  Detected version: ${JQ_VERSION} for arch: ${ARCHX}"

  if curl -sLo /usr/local/bin/jq "https://github.com/jqlang/jq/releases/download/${JQ_VERSION}/jq-linux-${ARCHX}"; then
    chmod +x /usr/local/bin/jq
    # Verify jq actually works
    if /usr/local/bin/jq --version >/dev/null 2>&1; then
      echo "  ✓ jq verified: $(/usr/local/bin/jq --version)"
    else
      echo "  ✗ jq download failed - binary not executable or corrupted"
      rm -f /usr/local/bin/jq
      record_failure "jq"
      exit 1
    fi
  else
    record_failure "jq"
    exit 1
  fi
}

install_crane() {
  echo "Installing crane..."
  curl -sLo- "https://github.com/google/go-containerregistry/releases/download/$(curl -s "https://api.github.com/repos/google/go-containerregistry/releases/latest" | jq -r '.tag_name')/go-containerregistry_Linux_${ARCHY}.tar.gz" | tar -C /usr/local/bin/ --no-same-owner -xzv crane krane gcrane || record_failure "crane"
}

install_helm() {
  echo "Installing helm..."
  # https://github.com/helm/helm/releases
  HELM_VERSION=$(curl -s "https://api.github.com/repos/helm/helm/releases/latest" | jq -r '.tag_name')
  curl -sSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCHX}.tar.gz" | tar -C /usr/local/bin/ --no-same-owner --strip-components=1 -xzv linux-${ARCHX}/helm || record_failure "helm"
}

install_skaffold() {
  echo "Installing skaffold..."
  # https://github.com/GoogleContainerTools/skaffold/releases
  SKAFFOLD_VERSION=$(curl -s "https://api.github.com/repos/GoogleContainerTools/skaffold/releases/latest" | jq -r '.tag_name')
  curl -sLo /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/${SKAFFOLD_VERSION}/skaffold-linux-${ARCHX} && chmod +x /usr/local/bin/skaffold || record_failure "skaffold"
}

install_yq() {
  echo "Installing yq..."
  # https://github.com/mikefarah/yq/releases
  YQ_VERSION=$(curl -s "https://api.github.com/repos/mikefarah/yq/releases/latest" | jq -r '.tag_name')
  curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCHX} && chmod +x /usr/local/bin/yq || record_failure "yq"
}

install_yj() {
  echo "Installing yj..."
  # https://github.com/sclevine/yj/releases
  YJ_VERSION=$(curl -s "https://api.github.com/repos/sclevine/yj/releases/latest" | jq -r '.tag_name')
  curl -sLo /usr/local/bin/yj https://github.com/sclevine/yj/releases/download/${YJ_VERSION}/yj-linux-${ARCHX} && chmod +x /usr/local/bin/yj || record_failure "yj"
}

install_ytt() {
  echo "Installing ytt..."
  # https://github.com/carvel-dev/ytt/releases
  YTT_VERSION=$(curl -s "https://api.github.com/repos/carvel-dev/ytt/releases/latest" | jq -r '.tag_name')
  curl -sLo /usr/local/bin/ytt https://github.com/carvel-dev/ytt/releases/download/${YTT_VERSION}/ytt-linux-${ARCHX} && chmod +x /usr/local/bin/ytt || record_failure "ytt"
}

install_regctl() {
  echo "Installing regctl..."
  # https://github.com/regclient/regclient/releases
  REGCTL_VERSION=$(curl -s "https://api.github.com/repos/regclient/regclient/releases/latest" | jq -r '.tag_name')
  curl -sLo /usr/local/bin/regctl https://github.com/regclient/regclient/releases/download/${REGCTL_VERSION}/regctl-linux-${ARCHX} && chmod +x /usr/local/bin/regctl || record_failure "regctl"
}

# Create lock file for synchronization
touch "$LOCK_FILE"

echo "Installing jq first (required by other tools)..."
echo "================================================"

# Install jq first - it's needed by most other tools to parse GitHub API responses
install_jq

# Verify jq is working before proceeding
if ! command -v jq >/dev/null 2>&1; then
  echo "ERROR: jq installation failed - cannot proceed"
  exit 1
fi

echo ""
echo "Starting batched parallel installation of remaining tools..."
echo "================================================"

# Batch installations to avoid overwhelming network/rate limits
# Max 5 concurrent downloads per batch

echo "Batch 1/4: kubectl, crane, regctl, ytt"
install_kubectl &
install_crane &
install_regctl &
install_ytt &
wait

echo "Batch 2/4: helm, skaffold, yq, yj"
install_helm &
install_skaffold &
install_yq &
install_yj &
wait

echo ""
echo "All batches completed!"

echo ""
echo "================================================"
echo "Installation complete!"

# Check for failures
if [[ -f /tmp/failed_tools.txt ]]; then
  echo ""
  echo "WARNING: The following tools failed to install:"
  cat /tmp/failed_tools.txt
  rm /tmp/failed_tools.txt
  exit 1
fi

# Final permissions pass
chmod +x /usr/local/bin/* 2>/dev/null || true

# Cleanup
rm -f "$LOCK_FILE"

echo ""
echo "Verifying installed tools..."
echo "================================================"

# Verify each tool
TOOLS=(
  "kubectl:kubectl version --client=true --output=yaml"
  "jq:jq --version"
  "crane:crane version"
  "helm:helm version"
  "skaffold:skaffold version"
  "yq:yq --version"
  "yj:yj -v"
  "ytt:ytt version"
  "regctl:regctl version"
)

FAILED_VERIFY=0
for tool_info in "${TOOLS[@]}"; do
  tool_name="${tool_info%%:*}"
  tool_cmd="${tool_info#*:}"

  if command -v "$tool_name" >/dev/null 2>&1; then
    if $tool_cmd >/dev/null 2>&1; then
      echo "  ✓ $tool_name"
    else
      echo "  ✗ $tool_name (installed but not working)"
      FAILED_VERIFY=$((FAILED_VERIFY + 1))
    fi
  else
    echo "  ✗ $tool_name (not found)"
    FAILED_VERIFY=$((FAILED_VERIFY + 1))
  fi
done

echo ""
if [[ $FAILED_VERIFY -gt 0 ]]; then
  echo "WARNING: $FAILED_VERIFY tool(s) failed verification"
  exit 1
else
  echo "All tools installed and verified successfully!"
fi

package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"regexp"
	"strings"

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

	// cache
	keychain authn.Keychain
}

func New(
	// +defaultPath="."
	// +ignore=["gitlab", ".git"]
	source *dagger.Directory,
	// +optional
	// +default="variables.yml"
	variablesFile string,
	// Target registry (default: cr.nrtn.dev, use DOCKER_HUB var in GitLab)
	// +optional
	// +default="cr.nrtn.dev"
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

// WithDockerCfg stores the secret on the object so it can be reused.
func (m *InfraSetup) WithDockerCfg(dockerCfg *dagger.Secret) *InfraSetup {
	// return a *new* configured object if you prefer immutability patterns
	m.DockerCfg = dockerCfg
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

// TestCrane tests crane copy functionality using the library (no external container)
func (m *InfraSetup) TestCrane(
	ctx context.Context,
) (string, error) {
	src := "alpine:3.22.2"
	dst := m.buildDestination(src, m.TargetRegistry, "")

	result, err := m.pullAndPush(ctx, src, dst)
	if err != nil {
		return "", err
	}

	return result, nil
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
	vars, err := m.loadVariables(ctx, m.Source.File(m.VariablesFile))
	if err != nil {
		return "", err
	}

	imageEntries := m.getImageEntries()
	var results strings.Builder
	matched := 0

	for _, entry := range imageEntries {
		expanded, prependName, err := m.expandImageEntry(entry, vars)
		if err != nil {
			return "", err
		}

		// If pattern is empty or matches
		if pattern == "" || strings.Contains(expanded, pattern) {
			source := expanded
			destination := m.buildDestination(expanded, m.TargetRegistry, prependName)
			results.WriteString(fmt.Sprintf("%s -> %s\n", source, destination))
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
	vars, err := m.loadVariables(ctx, m.Source.File(m.VariablesFile))
	if err != nil {
		return "", err
	}

	imageEntries := m.getImageEntries()
	var results strings.Builder
	matched := 0

	for i, entry := range imageEntries {
		expanded, prependName, err := m.expandImageEntry(entry, vars)
		if err != nil {
			return "", fmt.Errorf("image entry %d: %w", i+1, err)
		}

		// If pattern is empty or matches
		if pattern == "" || strings.Contains(expanded, pattern) {
			source := expanded
			destination := m.buildDestination(expanded, m.TargetRegistry, prependName)

			if _, err := m.pullAndPush(ctx, source, destination); err != nil {
				return "", fmt.Errorf("failed to import %s: %w", source, err)
			}

			results.WriteString(fmt.Sprintf("✓ %s -> %s\n", source, destination))
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

// getImageEntries returns all image entries in the dense format from bash
func (m *InfraSetup) getImageEntries() []string {
	return []string{
		"debian:${DEBIAN_VERSION}:::prepend_name=library/",
		"ubuntu:${UBUNTU_NOBLE_VERSION}:::prepend_name=library/",
		"alpine:${ALPINE_VERSION}:::prepend_name=library/",
		"busybox:${BUSYBOX_VERSION}:::prepend_name=library/",
		"node:${NODE_VERSION}:::prepend_name=library/",
		"python:${PYTHON_VERSION}:::prepend_name=library/",
		"python:${PYTHON_SLIM_VERSION}:::prepend_name=library/",
		"golang:${GOLANG_VERSION}:::prepend_name=library/",
		"golang:${GOLANG_ALPINE_VERSION}:::prepend_name=library/",
		"traefik:${TRAEFIK_VERSION}:::prepend_name=library/",
		"sonatype/nexus3:${NEXUS_VERSION}",
		"squidfunk/mkdocs-material:${MKDOCS_VERSION}",
		"freeradius/freeradius-server:${FREERADIUS_VERSION}",
		"quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}",
		"postgres:${POSTGRES_VERSION}:::prepend_name=library/",
		"prometheuscommunity/postgres-exporter:${POSTGRES_EXPORTER_VERSION}",
		"quay.io/minio/minio:${MINIO_VERSION}",
		"quay.io/minio/mc:${MINIO_MC_VERSION}",
		"quay.io/coreos/etcd:${ETCD_35_VERSION}",
		"quay.io/coreos/etcd:${ETCD_36_VERSION}",
		"quay.io/prometheus/prometheus:${PROMETHEUS_VERSION}",
		"quay.io/prometheus/alertmanager:${ALERTMANAGER_VERSION}",
		"quay.io/prometheus/node-exporter:${NODE_EXPORTER_VERSION}",
		"quay.io/prometheus/blackbox-exporter:${BLACKBOX_EXPORTER_VERSION}",
		"quay.io/prometheus/snmp-exporter:${SNMP_EXPORTER_VERSION}",
		"quay.io/prometheus/pushgateway:${PUSHGATEWAY_VERSION}",
		"quay.io/prometheus-operator/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION}",
		"quay.io/prometheus-operator/prometheus-config-reloader:${PROMETHEUS_OPERATOR_VERSION}",
		"registry.k8s.io/kube-state-metrics/kube-state-metrics:${KUBE_STATE_METRICS_VERSION}",
		"registry.k8s.io/metrics-server/metrics-server:${METRICS_SERVER_VERSION}",
		"grafana/grafana:${GRAFANA_VERSION}",
		"ghcr.io/prymitive/karma:${KARMA_VERSION}",
		"docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION}:::prepend_name=elastic/",
		"docker.elastic.co/logstash/logstash:${LOGSTASH_VERSION}:::prepend_name=elastic/",
		"docker.elastic.co/kibana/kibana:${KIBANA_VERSION}:::prepend_name=elastic/",
		"docker.elastic.co/apm/apm-server:${APMSERVER_VERSION}:::prepend_name=elastic/",
		"docker.elastic.co/beats/elastic-agent:${ELASTICAGENT_VERSION}:::prepend_name=elastic/",
		"mongo:${MONGODB_VERSION}:::prepend_name=library/",
		"percona/mongodb_exporter:${MONGODB_EXPORTER_VERSION}",
		"dpage/pgadmin4:${PGADMIN_VERSION}",
		"mccutchen/go-httpbin:${HTTPBIN_VERSION}",
		"quay.io/oauth2-proxy/oauth2-proxy:${OAUTH2_PROXY_VERSION}",
		"gitlab/gitlab-ce:${GITLAB_VERSION}",
		"gitlab/gitlab-runner:${GITLAB_RUNNER_VERSION}",
		"registry.gitlab.com/gitlab-org/gitlab-runner/gitlab-runner-helper:${GITLAB_RUNNER_HELPER_VERSION}",
		"registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/agentk:${GITLAB_AGENTK_VERSION}",
		"quay.io/brancz/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION}",
		"pihole/pihole:${PIHOLE_VERSION}",
		"klutchell/unbound:${UNBOUND_VERSION}",
		"nextcloud:${NEXTCLOUD_VERSION}:::prepend_name=library/",
		"docker:${DIND_VERSION}:::prepend_name=library/",
		"registry.k8s.io/ingress-nginx/controller:${NGINX_INGRESS_CONTROLLER_VERSION}",
		"registry.k8s.io/ingress-nginx/kube-webhook-certgen:${NGINX_INGRESS_KUBE_WEBHOOK_CERTGEN_VERSION}",
		"quay.io/metallb/controller:${METALLB_CONTROLLER_VERSION}",
		"quay.io/metallb/speaker:${METALLB_SPEAKER_VERSION}",
		"quay.io/frrouting/frr:${METALLB_FRR_VERSION}",
		"haproxytech/haproxy-alpine:${HAPROXY_VERSION}",
		"haproxytech/kubernetes-ingress:${HAPROXY_INGRESS_VERSION}",
		"aquasec/trivy:${TRIVY_VERSION}",
		"ghcr.io/external-secrets/external-secrets:${EXTERNAL_SECRETS_VERSION}",
		"registry.k8s.io/csi-secrets-store/driver:${CSI_SECRETS_STORE_VERSION}",
		"registry.k8s.io/csi-secrets-store/driver-crds:${CSI_SECRETS_STORE_VERSION}",
		"stakater/reloader:${RELOADER_VERSION}",
		"jimmidyson/configmap-reload:${CONFIGMAP_RELOAD_VERSION}",
		"registry:${DOCKER_REGISTRY_VERSION}:::prepend_name=library/",
		"ghcr.io/dexidp/dex:${DEX_VERSION}",
		"quay.io/argoproj/argocd:${ARGOCD_VERSION}",
		"valkey/valkey:${VALKEY_VERSION}",
		"redis:${REDIS_VERSION}:::prepend_name=library/",
		"oliver006/redis_exporter:${REDIS_EXPORTER_VERSION}",
		"boky/postfix:${BOKY_POSTFIX_VERSION}",
		"connecteverything/nats-operator:${NATS_OPERATOR_VERSION}",
		"nats:${NATS_VERSION}:::prepend_name=library/",
		"natsio/prometheus-nats-exporter:${NATS_EXPORTER_VERSION}",
		"natsio/nats-server-config-reloader:${NATS_SERVER_CONFIG_RELOADER}",
		"masipcat/wireguard-go:${WIREGUARD_VERSION}",
		"eclipse-mosquitto:${MOSQUITTO_VERSION}:::prepend_name=library/",
		"sapcc/mosquitto-exporter:${MOSQUITTO_EXPORTER_VERSION}",
		"caddy:${CADDY_VERSION}:::prepend_name=library/",
		"azul/zulu-openjdk:${JDK_ZULU_VERSION}",
		"eclipse-temurin:${JDK_TEMURIN_VERSION}:::prepend_name=library/",
		"elastic/eck-operator:${ECK_OPERATOR_VERSION}",
		"syncthing/syncthing:${SYNCTHING_VERSION}",
		"syncthing/discosrv:${SYNCTHING_VERSION}",
		"syncthing/relaysrv:${SYNCTHING_VERSION}",
		"jellyfin/jellyfin:${JELLYFIN_VERSION}",
		"haveagitgat/tdarr:${TDARR_VERSION}",
		"haveagitgat/tdarr_node:${TDARR_VERSION}",
		"curlimages/curl:${CURL_VERSION}",
		"restic/restic:${RESTIC_VERSION}",
		"coturn/coturn:${COTURN_VERSION}",
		"netboxcommunity/netbox:${NETBOX_VERSION}",
		"postgrest/postgrest:${POSTGREST_VERSION}",
		"quay.io/cephcsi/cephcsi:${CEPHCSI_VERSION}",
		"homeassistant/home-assistant:${HOMEASSISTANT_VERSION}",
		"koenkk/zigbee2mqtt:${ZIGBEE2MQTT_VERSION}",
		"registry.k8s.io/sig-storage/nfsplugin:${CSI_NFSPLUGIN_VERSION}",
		"cloudflare/cloudflared:${CLOUDFLARED_VERSION}",
		"registry.k8s.io/git-sync/git-sync:${GIT_SYNC_VERSION}",
		"apache/airflow:${AIRFLOW_VERSION}",
		"sj26/mailcatcher:${MAILCATCHER_VERSION}",
		"fatedier/frps:${FRP_VERSION}",
		"fatedier/frpc:${FRP_VERSION}",
		"docker.n8n.io/n8nio/n8n:${N8N_VERSION}",
		"netsampler/goflow2:${GOFLOW2_VERSION}",
		"ghcr.io/corentinth/it-tools:${ITTOOLS_VERSION}",
		"quay.io/openbgpd/openbgpd:${OPENBGPD_VERISON}",
		// jenkins
		"jenkins/jenkins:${JENKINS_VERSION}",
		"jenkins/agent:${JENKINS_AGENT_VERSION}",
		"jenkins/inbound-agent:${JENKINS_INBOUND_AGENT_VERSION}",
		"quay.io/kiwigrid/k8s-sidecar:${KIWIGRID_K8S_SIDECAR_VERSION}",
		// cert-manager
		"quay.io/jetstack/cert-manager-controller:${CERT_MANAGER_VERSION}",
		"quay.io/jetstack/cert-manager-cainjector:${CERT_MANAGER_VERSION}",
		"quay.io/jetstack/cert-manager-webhook:${CERT_MANAGER_VERSION}",
		"quay.io/jetstack/cert-manager-csi-driver:${CERT_MANAGER_CSI_DRIVER_VERSION}",
		"zachomedia/cert-manager-webhook-pdns:${CERT_MANAGER_WEBHOOK_PDNS_VERSION}",
		// vault
		"hashicorp/vault:${VAULT_VERSION}",
		"hashicorp/vault-k8s:${VAULT_K8S_VERSION}",
		"hashicorp/vault-csi-provider:${VAULT_CSI_PROVIDER_VERSION}",
		// k8s
		"registry.k8s.io/pause:${K8S_PAUSE_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/coredns/coredns:${COREDNS_VERSION}",
		// k8s 1.34.x
		"registry.k8s.io/kube-apiserver:${K8S_134_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-proxy:${K8S_134_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-scheduler:${K8S_134_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-controller-manager:${K8S_134_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-apiserver:${K8S_134_VERSION2}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-proxy:${K8S_134_VERSION2}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-scheduler:${K8S_134_VERSION2}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-controller-manager:${K8S_134_VERSION2}:::prepend_name=kubernetes/",
		// k8s 1.33.x
		"registry.k8s.io/kube-apiserver:${K8S_133_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-proxy:${K8S_133_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-scheduler:${K8S_133_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-controller-manager:${K8S_133_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-apiserver:${K8S_133_VERSION2}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-proxy:${K8S_133_VERSION2}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-scheduler:${K8S_133_VERSION2}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-controller-manager:${K8S_133_VERSION2}:::prepend_name=kubernetes/",
		// k8s 1.32.x
		"registry.k8s.io/kube-apiserver:${K8S_132_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-proxy:${K8S_132_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-scheduler:${K8S_132_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-controller-manager:${K8S_132_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-apiserver:${K8S_132_VERSION2}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-proxy:${K8S_132_VERSION2}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-scheduler:${K8S_132_VERSION2}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-controller-manager:${K8S_132_VERSION2}:::prepend_name=kubernetes/",
		// k8s 1.31.x
		"registry.k8s.io/kube-apiserver:${K8S_131_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-proxy:${K8S_131_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-scheduler:${K8S_131_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-controller-manager:${K8S_131_VERSION}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-apiserver:${K8S_131_VERSION2}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-proxy:${K8S_131_VERSION2}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-scheduler:${K8S_131_VERSION2}:::prepend_name=kubernetes/",
		"registry.k8s.io/kube-controller-manager:${K8S_131_VERSION2}:::prepend_name=kubernetes/",
		"rancher/kubectl:${KUBECTL_VERSION}",
		// calico
		"quay.io/tigera/operator:${TIGERA_OPERATOR_VERSION}",
		"calico/typha:${CALICO_VERSION}",
		"calico/ctl:${CALICO_VERSION}",
		"calico/node:${CALICO_VERSION}",
		"calico/cni:${CALICO_VERSION}",
		"calico/apiserver:${CALICO_VERSION}",
		"calico/kube-controllers:${CALICO_VERSION}",
		"calico/dikastes:${CALICO_VERSION}",
		"calico/pod2daemon-flexvol:${CALICO_VERSION}",
		"calico/node-driver-registrar:${CALICO_VERSION}",
		"calico/csi:${CALICO_VERSION}",
		// istio
		"istio/pilot:${ISTIO_VERSION}",
		"istio/proxyv2:${ISTIO_VERSION}",
		"istio/ztunnel:${ISTIO_VERSION}",
		// NFD
		"registry.k8s.io/nfd/node-feature-discovery:${K8S_NFD_VERSION}",
		// sig-storage
		"registry.k8s.io/sig-storage/livenessprobe:${LIVENESSPROBE_VERSION}",
		"registry.k8s.io/sig-storage/csi-node-driver-registrar:${CSI_NODE_DRIVER_REGISTRAR_VERSION}",
		"registry.k8s.io/sig-storage/csi-attacher:${CSI_ATTACHER_VERSION}",
		"registry.k8s.io/sig-storage/csi-resizer:${CSI_RESIZER_VERSION}",
		"registry.k8s.io/sig-storage/csi-provisioner:${CSI_PROVISIONER_VERSION}",
		"registry.k8s.io/sig-storage/csi-snapshotter:${CSI_SNAPSHOTTER_VERSION}",
		"registry.k8s.io/sig-storage/snapshot-controller:${CSI_SNAPSHOT_CONTROLLER_VERSION}",
		"registry.k8s.io/sig-storage/snapshot-validation-webhook:${CSI_SNAPSHOT_VALIDATION_WEBHOOK_VERSION}",
		// nvidia gpu operator
		"nvcr.io/nvidia/gpu-operator:${NVIDIA_GPU_OPERATOR_VERSION}",
		"nvcr.io/nvidia/cloud-native/gpu-operator-validator:${NVIDIA_GPU_OPERATOR_VALIDATOR_VERSION}",
		"nvcr.io/nvidia/cuda:${NVIDIA_CUDA_VERSION}",
		"nvcr.io/nvidia/cloud-native/k8s-driver-manager:${NVIDIA_K8S_DRIVER_MANAGER_VERSION}",
		"nvcr.io/nvidia/k8s/container-toolkit:${NVIDIA_K8S_CONTAINER_TOOLKIT_VERSION}",
		"nvcr.io/nvidia/k8s-device-plugin:${NVIDIA_K8S_DEVICE_PLUGIN_VERSION}",
		"nvcr.io/nvidia/cloud-native/dcgm:${NVIDIA_DCGM_VERSION}",
		"nvcr.io/nvidia/k8s/dcgm-exporter:${NVIDIA_DCGM_EXPORTER_VERSION}",
		"nvcr.io/nvidia/gpu-feature-discovery:${NVIDIA_GPU_FEATURE_DISCOVERY_VERSION}",
		"nvcr.io/nvidia/cloud-native/k8s-mig-manager:${NVIDIA_K8S_MIG_MANAGER_VERSION}",
		// kafka
		"apache/kafka:${APACHE_KAFKA_VERSION}",
		"quay.io/strimzi/operator:${STRIMZI_OPERATOR_VERSION}",
		"quay.io/strimzi/kafka:${STRIMZI_OPERATOR_VERSION}-kafka-${STRIMZI_KAFKA_VERSION}",
		// confluent
		"confluentinc/confluent-init-container:${CONFLUENTINC_INIT_CONTAINER_VERSION}",
		"confluentinc/confluent-operator:${CONFLUENTINC_OPERATOR_VERSION}",
		"confluentinc/cp-enterprise-control-center-next-gen:${CONFLUENTINC_ENTERPRISE_CONTROL_CENTER_VERSION}",
		"confluentinc/cp-enterprise-replicator:${CONFLUENTINC_CP_VERSION}",
		"confluentinc/cp-kafka-rest:${CONFLUENTINC_CP_VERSION}",
		"confluentinc/cp-ksqldb-server:${CONFLUENTINC_CP_VERSION}",
		"confluentinc/cp-schema-registry:${CONFLUENTINC_CP_VERSION}",
		"confluentinc/cp-server:${CONFLUENTINC_CP_VERSION}",
		"confluentinc/cp-server-connect:${CONFLUENTINC_CP_VERSION}",
		"obsidiandynamics/kafdrop:${KAFDROP_VERSION}",
		"tchiotludo/akhq:${AKHQ_VERSION}",
		// scylladb
		"scylladb/scylla:${SCYLLA_VERSION}",
		"scylladb/scylla-manager:${SCYLLA_MANAGER_VERSION}",
		"scylladb/scylla-operator:${SCYLLA_OPERATOR_VERSION}",
		// clickhouse
		"clickhouse:${CLICKHOUSE_VERSION}:::prepend_name=library/",
		"altinity/clickhouse-operator:${CLICHOUSE_OPERATOR_VERSION}",
		"rabbitmq:${RABBITMQ_VERSION}:::prepend_name=library/",
		"kbudde/rabbitmq-exporter:${RABBITMQ_EXPORTER_VERSION}",
		// prefect
		"prefecthq/prefect:${PREFECT_VERSION}",
		"prefecthq/prefect:${PREFECT_VERSION}-kubernetes",
		"prefecthq/prometheus-prefect-exporter:${PREFECT_EXPORTER_VERSION}",
		// forgejo
		"codeberg.org/forgejo/forgejo:${FORGEJO_VERSION}",
		"code.forgejo.org/forgejo/runner:${FORGEJO_RUNNER_VERSION}",
		"ghcr.io/catthehacker/ubuntu:act-24.04",
		"ghcr.io/catthehacker/ubuntu:runner-24.04",
	}
}

// expandImageEntry expands variables in an image entry and extracts options
func (m *InfraSetup) expandImageEntry(entry string, vars *Variables) (string, string, error) {
	parts := strings.Split(entry, ":::")
	imageSpec := parts[0]
	prependName := ""

	// Extract options
	if len(parts) > 1 {
		for _, opt := range parts[1:] {
			if val, ok := strings.CutPrefix(opt, "prepend_name="); ok {
				prependName = val
			}
		}
	}

	// Expand variables
	expanded, err := m.expandVariables(imageSpec, vars)
	if err != nil {
		return "", "", err
	}

	return expanded, prependName, nil
}

// expandVariables expands ${VAR} references, throwing error if variable not found
func (m *InfraSetup) expandVariables(s string, vars *Variables) (string, error) {
	re := regexp.MustCompile(`\$\{([^}]+)\}`)

	result := s
	matches := re.FindAllStringSubmatch(s, -1)

	for _, match := range matches {
		varName := match[1]
		value, ok := vars.Variables[varName]
		if !ok {
			return "", fmt.Errorf("variable not defined: %s", varName)
		}
		result = strings.ReplaceAll(result, match[0], value)
	}

	return result, nil
}

// buildDestination constructs the destination image reference
func (m *InfraSetup) buildDestination(source, targetRegistry, prependName string) string {
	parts := strings.SplitN(source, "/", 2)

	var imageName string
	if len(parts) == 1 {
		// No registry/org prefix (e.g., "debian:tag")
		imageName = parts[0]
	} else if strings.Contains(parts[0], ".") {
		// Has registry prefix (e.g., "quay.io/minio/minio:tag")
		imageName = parts[1]
	} else {
		// Has org prefix (e.g., "gitlab/gitlab-ce:tag")
		imageName = source
	}

	return targetRegistry + "/" + prependName + imageName
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

	fmt.Fprintf(os.Stdout, "%s -> %s\n", source, destination)

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
	vars, err := m.loadVariables(ctx, m.Source.File(m.VariablesFile))
	if err != nil {
		return nil, err
	}

	imageEntries := m.getImageEntries()

	// Generate Dockerfile
	var dockerfile strings.Builder
	var upstreamImages []string

	for _, entry := range imageEntries {
		expanded, _, err := m.expandImageEntry(entry, vars)
		if err != nil {
			return nil, fmt.Errorf("expanding image entry: %w", err)
		}

		// Extract image name for comment
		parts := strings.SplitN(expanded, ":", 2)
		imageName := parts[0]

		dockerfile.WriteString(fmt.Sprintf("# %s\n", imageName))
		dockerfile.WriteString(fmt.Sprintf("FROM %s\n", expanded))
		dockerfile.WriteString(fmt.Sprintf("# %s\n\n", imageName))

		upstreamImages = append(upstreamImages, expanded)
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

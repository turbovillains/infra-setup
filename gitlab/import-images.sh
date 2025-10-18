#!/usr/bin/env bash

import_images() {
    declare -a images=(
        "debian:${DEBIAN_VERSION:-11.0-slim}:::prepend_name=library/"
        "ubuntu:${UBUNTU_NOBLE_VERSION:-focal-20240212}:::prepend_name=library/"
        "alpine:${ALPINE_VERSION:-3.14.0}:::prepend_name=library/"
        "busybox:${BUSYBOX_VERSION:-1.34.1}:::prepend_name=library/"
        "node:${NODE_VERSION:-22.4.1-bookworm}:::prepend_name=library/"
        "node:${NODE_ALPINE_VERSION:-22.4.1-bookworm}:::prepend_name=library/"
        "python:${PYTHON_VERSION:-3.11.2}:::prepend_name=library/"
        "python:${PYTHON_SLIM_VERSION:-3.11.2-slim}:::prepend_name=library/"
        "golang:${GOLANG_VERSION:-1.17.3-bullseye}:::prepend_name=library/"
        "golang:${GOLANG_ALPINE_VERSION:-1.17.3-alpine3.14}:::prepend_name=library/"
        "traefik:${TRAEFIK_VERSION:-latest}:::prepend_name=library/"
        "sonatype/nexus3:${NEXUS_VERSION:-3.37.3}"
        "squidfunk/mkdocs-material:${MKDOCS_VERSION:-latest}"
        "freeradius/freeradius-server:${FREERADIUS_VERSION:-latest}"
        "quay.io/keycloak/keycloak:${KEYCLOAK_VERSION:-11.0.2}"
        "postgres:${POSTGRES_VERSION:-13.0}:::prepend_name=library/"
        "prometheuscommunity/postgres-exporter:${POSTGRES_EXPORTER_VERSION:-v0.18.1}"
        "quay.io/minio/minio:${MINIO_VERSION:-RELEASE.2021-02-07T01-31-02Z}"
        "quay.io/minio/mc:${MINIO_MC_VERSION:-RELEASE.2024-04-18T16-45-29Z}"
        "quay.io/coreos/etcd:${ETCD_35_VERSION:-latest}"
        "quay.io/coreos/etcd:${ETCD_36_VERSION:-latest}"
        "quay.io/prometheus/prometheus:${PROMETHEUS_VERSION:-latest}"
        "quay.io/prometheus/alertmanager:${ALERTMANAGER_VERSION:-latest}"
        "quay.io/prometheus/node-exporter:${NODE_EXPORTER_VERSION:-latest}"
        "quay.io/prometheus/blackbox-exporter:${BLACKBOX_EXPORTER_VERSION:-latest}"
        "quay.io/prometheus/snmp-exporter:${SNMP_EXPORTER_VERSION:-latest}"
        "quay.io/prometheus/pushgateway:${PUSHGATEWAY_VERSION:-latest}"
        "quay.io/prometheus-operator/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION:-latest}"
        "quay.io/prometheus-operator/prometheus-config-reloader:${PROMETHEUS_OPERATOR_VERSION:-latest}"
        "registry.k8s.io/kube-state-metrics/kube-state-metrics:${KUBE_STATE_METRICS_VERSION:-v2.17.0}"
        "registry.k8s.io/metrics-server/metrics-server:${METRICS_SERVER_VERSION:-v0.8.0}"
        "grafana/grafana:${GRAFANA_VERSION:-8.4.5}"
        "ghcr.io/prymitive/karma:${KARMA_VERSION:-latest}"
        "docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION:-latest}:::prepend_name=elastic/"
        "docker.elastic.co/logstash/logstash:${LOGSTASH_VERSION:-latest}:::prepend_name=elastic/"
        "docker.elastic.co/kibana/kibana:${KIBANA_VERSION:-latest}:::prepend_name=elastic/"
        "docker.elastic.co/apm/apm-server:${APMSERVER_VERSION:-latest}:::prepend_name=elastic/"
        "docker.elastic.co/beats/elastic-agent:${ELASTICAGENT_VERSION:-latest}:::prepend_name=elastic/"
        "mongo:${MONGODB_VERSION:-latest}:::prepend_name=library/"
        "percona/mongodb_exporter:${MONGODB_EXPORTER_VERSION:-0.47.1}"
        "dpage/pgadmin4:${PGADMIN_VERSION:-5.0}"
        "mccutchen/go-httpbin:${HTTPBIN_VERSION}"
        "quay.io/oauth2-proxy/oauth2-proxy:${OAUTH2_PROXY_VERSION:-v7.1.2}"
        "gitlab/gitlab-ce:${GITLAB_VERSION:-14.1.2-ce.0}"
        "gitlab/gitlab-runner:${GITLAB_RUNNER_VERSION:-alpine-v13.12.0-rc1}"
        "registry.gitlab.com/gitlab-org/gitlab-runner/gitlab-runner-helper:${GITLAB_RUNNER_HELPER_VERSION:-x86_64-v16.10.0}"
        "registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/agentk:${GITLAB_AGENTK_VERSION:-v15.0.0}"
        "quay.io/brancz/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION:-v0.12.0}"
        "pihole/pihole:${PIHOLE_VERSION:-v5.8.1}"
        "klutchell/unbound:${UNBOUND_VERSION:-v1.19.3}"
        "nextcloud:${NEXTCLOUD_VERSION:-20.0.0-fpm-alpine}:::prepend_name=library/"
        "docker:${DIND_VERSION:-20.10.7-dind}:::prepend_name=library/"
        "registry.k8s.io/ingress-nginx/controller:${NGINX_INGRESS_CONTROLLER_VERSION:-v1.13.3}"
        "registry.k8s.io/ingress-nginx/kube-webhook-certgen:${NGINX_INGRESS_KUBE_WEBHOOK_CERTGEN_VERSION:-v1.6.3}"
        "quay.io/metallb/controller:${METALLB_CONTROLLER_VERSION:-0.15.2}"
        "quay.io/metallb/speaker:${METALLB_SPEAKER_VERSION:-0.15.2}"
        "quay.io/frrouting/frr:${METALLB_FRR_VERSION:-9.1.0}"
        "haproxytech/haproxy-alpine:${HAPROXY_VERSION:-3.1.5}"
        "haproxytech/kubernetes-ingress:${HAPROXY_INGRESS_VERSION:-3.1.2}"
        "aquasec/trivy:${TRIVY_VERSION:-0.33.0}"
        "ghcr.io/external-secrets/external-secrets:${EXTERNAL_SECRETS_VERSION:-v0.5.3}"
        "registry.k8s.io/csi-secrets-store/driver:${CSI_SECRETS_STORE_VERSION:-v0.4.3}"
        "registry.k8s.io/csi-secrets-store/driver-crds:${CSI_SECRETS_STORE_VERSION:-v0.4.3}"
        "stakater/reloader:${RELOADER_VERSION:-v0.0.97}"
        "jimmidyson/configmap-reload:${CONFIGMAP_RELOAD_VERSION:-v0.5.0}"
        "registry:${DOCKER_REGISTRY_VERSION:-2.7.1}:::prepend_name=library/"
        "ghcr.io/dexidp/dex:${DEX_VERSION:-v2.30.0}"
        "quay.io/argoproj/argocd:${ARGOCD_VERSION:-v2.1.0-rc2}"
        "valkey/valkey:${VALKEY_VERSION:-6.2.5-buster}"
        "redis:${REDIS_VERSION:-6.2.5-buster}:::prepend_name=library/"
        "oliver006/redis_exporter:${REDIS_EXPORTER_VERSION:-v1.77.0}"
        "boky/postfix:${BOKY_POSTFIX_VERSION:-v3.4.0}"
        "connecteverything/nats-operator:${NATS_OPERATOR_VERSION:-0.7.4}"
        "nats:${NATS_VERSION:-2.7.4-alpine3.15}:::prepend_name=library/"
        "natsio/prometheus-nats-exporter:${NATS_EXPORTER_VERSION:-0.10.1}"
        "natsio/nats-server-config-reloader:${NATS_SERVER_CONFIG_RELOADER:-0.10.1}"
        "masipcat/wireguard-go:${WIREGUARD_VERSION:-0.0.20220316}"
        "eclipse-mosquitto:${MOSQUITTO_VERSION:-2.0.14-openssl}:::prepend_name=library/"
        "sapcc/mosquitto-exporter:${MOSQUITTO_EXPORTER_VERSION:-0.8.0}"
        "caddy:${CADDY_VERSION:-2.5.1}:::prepend_name=library/"
        "azul/zulu-openjdk:${JDK_ZULU_VERSION:-18.0.1-18.30.11}"
        "eclipse-temurin:${JDK_TEMURIN_VERSION:-20_36-jdk-jammy}:::prepend_name=library/"
        "elastic/eck-operator:${ECK_OPERATOR_VERSION:-2.3.0}"
        "syncthing/syncthing:${SYNCTHING_VERSION:-1.22.1}"
        "syncthing/discosrv:${SYNCTHING_VERSION:-1.22.1}"
        "syncthing/relaysrv:${SYNCTHING_VERSION:-1.22.1}"
        "jellyfin/jellyfin:${JELLYFIN_VERSION:-10.8.7}"
        "haveagitgat/tdarr:${TDARR_VERSION:-2.200.25}"
        "haveagitgat/tdarr_node:${TDARR_VERSION:-2.200.25}"
        "curlimages/curl:${CURL_VERSION:-8.7.1}"
        "restic/restic:${RESTIC_VERSION:-0.14.0}"
        "coturn/coturn:${COTURN_VERSION:-4.6.1}"
        "netboxcommunity/netbox:${NETBOX_VERSION:-v3.4.5}"
        "postgrest/postgrest:${POSTGREST_VERSION:-v10.2.0.20230209}"
        "quay.io/cephcsi/cephcsi:${CEPHCSI_VERSION:-v3.10.2}"
        "homeassistant/home-assistant:${HOMEASSISTANT_VERSION:-2024.4}"
        "koenkk/zigbee2mqtt:${ZIGBEE2MQTT_VERSION:-1.36.1}"
        "registry.k8s.io/sig-storage/nfsplugin:${CSI_NFSPLUGIN_VERSION:-4.6.0}"
        "gitea/gitea:${GITEA_VERSION:-1.21.11}"
        "cloudflare/cloudflared:${CLOUDFLARED_VERSION:-2024.6.1}"
        "registry.k8s.io/git-sync/git-sync:${GIT_SYNC_VERSION:-v3.6.1}"
        "apache/airflow:${AIRFLOW_VERSION:-2.3.4-python3.10}"
        "sj26/mailcatcher:${MAILCATCHER_VERSION:-v0.10.0}"
        "fatedier/frps:${FRP_VERSION:-v0.16.1}"
        "fatedier/frpc:${FRP_VERSION:-v0.16.1}"
        "docker.n8n.io/n8nio/n8n:${N8N_VERSION:-1.50.0}"
        "netsampler/goflow2:${GOFLOW2_VERSION:-v2.2.1}"
        "ghcr.io/corentinth/it-tools:${ITTOOLS_VERSION:-2024.5.13-a0bc346}"
        "quay.io/openbgpd/openbgpd:${OPENBGPD_VERISON:-"8.6"}"

        # jenkins
        "jenkins/jenkins:${JENKINS_VERSION:-2.389-jdk17}"
        "jenkins/agent:${JENKINS_AGENT_VERSION:-3085.vc4c6977c075a-5-jdk17}"
        "jenkins/inbound-agent:${JENKINS_INBOUND_AGENT_VERSION:-3273.v4cfe589b_fd83-1-jdk17}"
        "quay.io/kiwigrid/k8s-sidecar:${KIWIGRID_K8S_SIDECAR_VERSION:-1.28.4}"

        # cert-manager
        "quay.io/jetstack/cert-manager-controller:${CERT_MANAGER_VERSION:-v1.8.0}"
        "quay.io/jetstack/cert-manager-cainjector:${CERT_MANAGER_VERSION:-v1.8.0}"
        "quay.io/jetstack/cert-manager-webhook:${CERT_MANAGER_VERSION:-v1.8.0}"
        # "quay.io/jetstack/cert-manager-ctl:${CERT_MANAGER_VERSION:-v1.8.0}"
        "quay.io/jetstack/cert-manager-csi-driver:${CERT_MANAGER_CSI_DRIVER_VERSION:-v0.3.0}"
        "zachomedia/cert-manager-webhook-pdns:${CERT_MANAGER_WEBHOOK_PDNS_VERSION:-v2.0.1}"

        # consul
        "hashicorp/vault:${VAULT_VERSION:-1.10.0}"
        "hashicorp/vault-k8s:${VAULT_K8S_VERSION:-0.15.0}"
        "hashicorp/vault-csi-provider:${VAULT_CSI_PROVIDER_VERSION:-1.1.0}"

        # k8s
        "registry.k8s.io/pause:${K8S_PAUSE_VERSION:-3.7}:::prepend_name=kubernetes/"
        "registry.k8s.io/coredns/coredns:${COREDNS_VERSION:-v1.8.6}"

        # k8s 1.34.x
        "registry.k8s.io/kube-apiserver:${K8S_134_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_134_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_134_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_134_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-apiserver:${K8S_134_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_134_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_134_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_134_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"

        # k8s 1.33.x
        "registry.k8s.io/kube-apiserver:${K8S_133_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_133_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_133_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_133_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-apiserver:${K8S_133_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_133_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_133_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_133_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"

        # k8s 1.32.x
        "registry.k8s.io/kube-apiserver:${K8S_132_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_132_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_132_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_132_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-apiserver:${K8S_132_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_132_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_132_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_132_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"

        # k8s 1.31.x
        "registry.k8s.io/kube-apiserver:${K8S_131_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_131_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_131_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_131_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-apiserver:${K8S_131_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_131_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_131_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_131_VERSION2:-v1.23.5}:::prepend_name=kubernetes/"

        "rancher/kubectl:${KUBECTL_VERSION:-v1.34.1}"

        # calico
        "quay.io/tigera/operator:${TIGERA_OPERATOR_VERSION:-v1.25.3}"
        "calico/typha:${CALICO_VERSION:-v3.22.1}"
        "calico/ctl:${CALICO_VERSION:-v3.22.1}"
        "calico/node:${CALICO_VERSION:-v3.22.1}"
        "calico/cni:${CALICO_VERSION:-v3.22.1}"
        "calico/apiserver:${CALICO_VERSION:-v3.22.1}"
        "calico/kube-controllers:${CALICO_VERSION:-v3.22.1}"
        "calico/dikastes:${CALICO_VERSION:-v3.22.1}"
        "calico/pod2daemon-flexvol:${CALICO_VERSION:-v3.22.1}"
        "calico/node-driver-registrar:${CALICO_VERSION:-v3.22.1}"
        "calico/csi:${CALICO_VERSION:-v3.22.1}"

        # istio
        "istio/pilot:${ISTIO_VERSION:-1.27.0}"
        "istio/proxyv2:${ISTIO_VERSION:-1.27.0}"
        "istio/ztunnel:${ISTIO_VERSION:-1.27.0}"

        # NFD
        "registry.k8s.io/nfd/node-feature-discovery:${K8S_NFD_VERSION:-v0.13.3}"
        
        # sig-storage
        "registry.k8s.io/sig-storage/livenessprobe:${LIVENESSPROBE_VERSION:-v2.7.0}"
        "registry.k8s.io/sig-storage/csi-node-driver-registrar:${CSI_NODE_DRIVER_REGISTRAR_VERSION:-v2.5.1}"
        "registry.k8s.io/sig-storage/csi-attacher:${CSI_ATTACHER_VERSION:-v3.4.0}"
        "registry.k8s.io/sig-storage/csi-resizer:${CSI_RESIZER_VERSION:-v1.4.0}"
        "registry.k8s.io/sig-storage/csi-provisioner:${CSI_PROVISIONER_VERSION:-v3.1.0}"
        "registry.k8s.io/sig-storage/csi-snapshotter:${CSI_SNAPSHOTTER_VERSION:-v5.0.1}"
        "registry.k8s.io/sig-storage/snapshot-controller:${CSI_SNAPSHOT_CONTROLLER_VERSION:-v5.0.1}"
        "registry.k8s.io/sig-storage/snapshot-validation-webhook:${CSI_SNAPSHOT_VALIDATION_WEBHOOK_VERSION:-v5.0.1}"

        # nvidia gpu operator shit, https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/install-gpu-operator-air-gapped.html
        "nvcr.io/nvidia/gpu-operator:${NVIDIA_GPU_OPERATOR_VERSION:-v23.9.2}"
        "nvcr.io/nvidia/cloud-native/gpu-operator-validator:${NVIDIA_GPU_OPERATOR_VALIDATOR_VERSION:-v23.9.2}"
        "nvcr.io/nvidia/cuda:${NVIDIA_CUDA_VERSION:-12.3.2-base}"
        "nvcr.io/nvidia/cloud-native/k8s-driver-manager:${NVIDIA_K8S_DRIVER_MANAGER_VERSION:-v0.6.7}"
        # "nvcr.io/nvidia/cloud-native/k8s-driver-manager:v0.6.4"
        # "nvcr.io/nvidia/cloud-native/k8s-driver-manager:v0.6.2"
        "nvcr.io/nvidia/k8s/container-toolkit:${NVIDIA_K8S_CONTAINER_TOOLKIT_VERSION:-v1.14.6-ubi8}"
        "nvcr.io/nvidia/k8s-device-plugin:${NVIDIA_K8S_DEVICE_PLUGIN_VERSION:-v0.14.5-ubi8}"
        "nvcr.io/nvidia/cloud-native/dcgm:${NVIDIA_DCGM_VERSION:-3.3.3-1-ubi9}"
        "nvcr.io/nvidia/k8s/dcgm-exporter:${NVIDIA_DCGM_EXPORTER_VERSION:-3.3.5-3.4.0-ubi9}"
        "nvcr.io/nvidia/gpu-feature-discovery:${NVIDIA_GPU_FEATURE_DISCOVERY_VERSION:-v0.8.2-ubi8}"
        "nvcr.io/nvidia/cloud-native/k8s-mig-manager:${NVIDIA_K8S_MIG_MANAGER_VERSION:-v0.6.0-ubi8}"
        # "nvcr.io/nvidia/cloud-native/nvidia-fs:2.17.5"
        # "nvcr.io/nvidia/cloud-native/vgpu-device-manager:v0.2.4"
        # "nvcr.io/nvidia/cloud-native/kata-gpu-artifacts:ubuntu22.04-535.54.03"
        # "nvcr.io/nvidia/cloud-native/kata-gpu-artifacts:ubuntu22.04-535.86.10-snp"
        # "nvcr.io/nvidia/cloud-native/k8s-kata-manager:v0.1.2"
        # "nvcr.io/nvidia/kubevirt-gpu-device-plugin:v1.2.4"
        # "nvcr.io/nvidia/cloud-native/k8s-cc-manager:v0.1.1"

        # kafka
        "apache/kafka:${APACHE_KAFKA_VERSION:-4.1.0}"
        "quay.io/strimzi/operator:${STRIMZI_OPERATOR_VERSION:-0.28.0}"
        "quay.io/strimzi/kafka:${STRIMZI_OPERATOR_VERSION:-0.28.0}-kafka-${STRIMZI_KAFKA_VERSION:-3.1.0}"

        # confluent shit, https://docs.confluent.io/operator/current/co-custom-registry.html
        "confluentinc/confluent-init-container:${CONFLUENTINC_INIT_CONTAINER_VERSION:-2.3.1}"
        "confluentinc/confluent-operator:${CONFLUENTINC_OPERATOR_VERSION:-0.435.23}"
        "confluentinc/cp-enterprise-control-center-next-gen:${CONFLUENTINC_ENTERPRISE_CONTROL_CENTER_VERSION:-2.2.1}"
        "confluentinc/cp-enterprise-replicator:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-kafka-rest:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-ksqldb-server:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        # "confluentinc/cp-ksqldb-cli:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-schema-registry:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-server:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-server-connect:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "obsidiandynamics/kafdrop:${KAFDROP_VERSION:-3.30.0}"
        "tchiotludo/akhq:${AKHQ_VERSION:-0.21.0}"

        # scylladb
        "scylladb/scylla:${SCYLLA_VERSION:-5.4.7}"
        "scylladb/scylla-manager:${SCYLLA_MANAGER_VERSION:-3.2.8}"
        "scylladb/scylla-operator:${SCYLLA_OPERATOR_VERSION:-1.12.2}"

        # clickhouse
        "clickhouse:${CLICKHOUSE_VERSION:-21.5.6-alpine}:::prepend_name=library/"
        "altinity/clickhouse-operator:${CLICHOUSE_OPERATOR_VERSION:-0.25.4}"

        "rabbitmq:${RABBITMQ_VERSION:-4.1.4}:::prepend_name=library/"
        "kbudde/rabbitmq-exporter:${RABBITMQ_EXPROTER_VERSION:-1.0.0}"
    )

    local target_registry=${1:-${DOCKER_HUB:-cr.nrtn.dev}}

    for image_entry in "${images[@]}"; do
        image=$(strip_options ${image_entry})
        image_options=$(get_options ${image_entry})
        printf "\nMigrating %s/%s:%s to %s\n$(line)\n" \
            $(get_registry $image) $(get_name $image) $(get_tag $image) \
            ${target_registry}
        migrate_image "${image}" "${target_registry}" "${image_options}"
    done

    local infra_json="infra.json"
    # Sync to upstream repo for dependabot and renovate
    ssh-keyscan github.com | tee -a ~/.ssh/known_hosts
    git clone git@github.com:noroutine/upstream.git upstream
    (
        cd upstream

        # dockerfile
        for image_entry in "${images[@]}"; do
            image=$(strip_options ${image_entry})
            echo "# $(get_name ${image})"
            echo "FROM ${image}"
            echo "# $(get_name ${image})"
            echo
        done | tee Dockerfile

        jq -r -n --arg INFRA_VERSION ${INFRA_VERSION} '{ version: $INFRA_VERSION }' | tee ${infra_json}

        # components, variables, upstream images inside json
        for image_entry in "${images[@]}"; do
            image=$(strip_options ${image_entry})
            local component_base=$(get_name ${image})
            local component_base_version=$(get_tag ${image})
            local component_name=$(get_name ${image} | tr '/' '-')
            local component_var_key=$(get_name ${image} | tr '/-' '_' | tr '[:lower:]' '[:upper:]')

            echo "Adding upstream image: ${image}"
            cat ${infra_json} | jq -r --arg IMAGE ${image} '.upstream.images += [$IMAGE]' >${infra_json}.tmp
            mv ${infra_json}.tmp ${infra_json}

            # for infra_component_dockerfile in $(grep -rl }/${component_base}: ../docker | grep Dockerfile | xargs echo); do
            #     echo "Inspecting ${infra_component_dockerfile}"
            #     # find component name from docker/ as we named it
            #     local infra_component_name=$(dirname ${infra_component_dockerfile} | sed 's,^../docker/,,' | tr '/' '-')
            #     # find proper variable name for version from dockerfile
            #     local infra_component_version_variable=$(grep FROM ${infra_component_dockerfile} | grep ${component_base} ${infra_component_dockerfile} | cut -d ':' -f2 | sed 's,${,,;s,},,')
            #     # find proper version variable value from variables.yml
            #     local infra_component_version_value=$(yj < ../variables.yml | jq -r --arg VAR ${infra_component_version_variable} '.variables[$VAR]')

            #     echo "FROM ${infra_component_name}:\${${infra_component_version_variable}:-${infra_component_version_value}}"

            #     # remember version variable and value
            #     cat ${infra_json} | jq -r \
            #         --arg COMPONENT_VERSION_VAR "${infra_component_version_variable}" \
            #         --arg COMPONENT_VERSION_VALUE ${infra_component_version_value} \
            #         '.variables[$COMPONENT_VERSION_VAR] = $COMPONENT_VERSION_VALUE' > ${infra_json}.tmp
            #     mv ${infra_json}.tmp ${infra_json}

            #     cat ${infra_json} | jq -r \
            #         --arg COMPONENT_BASE "${component_base}" \
            #         --arg INFRA_COMPONENT_NAME "${infra_component_name}" \
            #         --arg INFRA_COMPONENT_VERSION_VARIABLE "${infra_component_version_variable}" \
            #         '.components[$INFRA_COMPONENT_NAME] = { name: $INFRA_COMPONENT_NAME, base: $COMPONENT_BASE, "version-variable": $INFRA_COMPONENT_VERSION_VARIABLE }' > ${infra_json}.tmp
            #     mv ${infra_json}.tmp ${infra_json}
            # done
        done

        cat ${infra_json}

        git add Dockerfile infra.json
        git commit -a -m "Infra ${INFRA_VERSION}" || true
        git push origin master

        # Tag if we are doing this for tag
        if [[ ! -z ${CI_COMMIT_TAG:-} ]]; then
            git tag ${CI_COMMIT_TAG}
            git push origin ${CI_COMMIT_TAG}
        fi
    )
}

_main() {
    set -eu
    local source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
    source ${source_dir}/env.sh

    import_images
}

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || _main "${@:-}"

# End of file

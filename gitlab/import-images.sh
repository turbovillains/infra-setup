#!/bin/bash -eu

get_registry() {
    local image=$1
    [[ -z ${image} ]] && return
    if [[ ${image} =~ ^([^\/]+\.[^\/]+)\/ ]]; then
        echo -n ${BASH_REMATCH[1]}
    else
        echo -n docker.io
    fi
}

get_tag() {
    local image=$1
    [[ -z ${image} ]] && echo -n "latest" && return
    if [[ ${image} =~ :([^\/]+) ]]; then
        echo -n ${BASH_REMATCH[1]}
    else
        echo -n "latest"
    fi
}

get_name() {
    local image=$1
    [[ -z ${image} ]] && return
    if [[ ${image} =~ ([^\/]+\.[^\/]+\/)?([^:]+)(:.+)?$ ]]; then
        echo -n ${BASH_REMATCH[2]}
    fi
}

migrate_image() {
    local image=$1
    [[ -z ${image} ]] && return
    local source_registry=$(get_registry ${image})
    local target_registry=${2}
    [[ -z ${target_registry} ]] && return
    local image_name=$(get_name ${image})
    local image_tag=$(get_tag ${image})

    set +e
    docker manifest inspect ${target_registry}/${image_name}:${image_tag} 2>&1> /dev/null
    local inspect_code=$?
    set -e

    if [[ "${inspect_code}" != 0 ]]; then    
        docker pull ${source_registry}/${image_name}:${image_tag}
        docker tag ${source_registry}/${image_name}:${image_tag} ${target_registry}/${image_name}:${image_tag}
        docker push ${target_registry}/${image_name}:${image_tag}
    fi

}

line() {
    local width=40
    # if [[ ! -z $TERM ]]; then
    #     width=$(tput cols)
    # fi

    eval printf '%.0s-' {1..${width}}
}

import_images() {
    declare -a images=(
        "debian:${DEBIAN_VERSION:-11.0-slim}"
        "ubuntu:${UBUNTU_JAMMY_VERSION:-jammy-20220315}"
        "ubuntu:${UBUNTU_FOCAL_VERSION:-focal-20210723}"
        "alpine:${ALPINE_VERSION:-3.14.0}"
        "busybox:${BUSYBOX_VERSION:-1.34.1}"
        "php:${PHP_VERSION:-8.1.0-apache}"
        "golang:${GOLANG_VERSION:-1.17.3-bullseye}"
        "golang:${GOLANG_ALPINE_VERSION:-1.17.3-alpine3.14}"
        "traefik:${TRAEFIK_VERSION:-latest}"
        "sonatype/nexus3:${NEXUS_VERSION:-3.37.3}"
        "squidfunk/mkdocs-material:${MKDOCS_VERSION:-latest}"
        "freeradius/freeradius-server:${FREERADIUS_VERSION:-latest}"
        "quay.io/keycloak/keycloak:${KEYCLOAK_VERSION:-11.0.2}"
        "postgres:${POSTGRES_VERSION:-13.0}"
        "atlassian/jira-software:${JIRA_VERSION:-8.13.0}"
        "nextcloud:${NEXTCLOUD_VERSION:-20.0.0-fpm-alpine}"
        "haproxytech/haproxy-debian:${HAPROXY_VERSION:-2.3.4}"
        "minio/minio:${MINIO_VERSION:-RELEASE.2021-02-07T01-31-02Z}"
        "quay.io/coreos/etcd:${ETCD_VERSION:-latest}"
        "prom/prometheus:${PROMETHEUS_VERSION:-latest}"
        "prom/alertmanager:${ALERTMANAGER_VERSION:-latest}"
        "prom/node-exporter:${NODE_EXPORTER_VERSION:-latest}"
        "prom/consul-exporter:${CONSUL_EXPORTER_VERSION:-latest}"
        "prom/blackbox-exporter:${BLACKBOX_EXPORTER_VERSION:-latest}"
        "prom/snmp-exporter:${SNMP_EXPORTER_VERSION:-latest}"
        "prom/pushgateway:${PUSHGATEWAY_VERSION:-latest}"
        "grafana/grafana:${GRAFANA_VERSION:-latest}"
        "quay.io/m3db/m3coordinator:${M3COORDINATOR_VERSION:-latest}"
        "quay.io/m3db/m3dbnode:${M3DBNODE_VERSION:-latest}"
        "braedon/prometheus-es-exporter:${PROMETHEUS_ES_EXPORTER_VERSION:-latest}"
        "ribbybibby/ssl-exporter:${SSL_EXPORTER_VERSION:-latest}"
        "gcr.io/cadvisor/cadvisor:${CADVISOR_VERSION:-latest}"
        "lmierzwa/karma:${KARMA_VERSION:-latest}"
        "quay.io/cortexproject/cortex:${CORTEX_VERSION:-latest}"
        "docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION:-latest}"
        "docker.elastic.co/logstash/logstash:${LOGSTASH_VERSION:-latest}"
        "docker.elastic.co/kibana/kibana:${KIBANA_VERSION:-latest}"
        "alerta/alerta-web:${ALERTA_VERSION:-latest}"
        "mongo:${MONGO_VERSION:-latest}"
        "wordpress:${WORDPRESS_VERSION:-5.7.0-apache}"
        "dpage/pgadmin4:${PGADMIN_VERSION:-5.0}"
        "mysql:${MYSQL_VERSION}"
        "mariadb:${MARIADB_VERSION}"
        "mccutchen/go-httpbin:${HTTPBIN_VERSION}"
        "quay.io/oauth2-proxy/oauth2-proxy:${OAUTH2_PROXY_VERSION:-v7.1.2-amd64}"
        "heroku/heroku:20-build"
        "heroku/heroku:20"
        "heroku/heroku:22-build"
        "heroku/heroku:22"
        "heroku/procfile-cnb:${HEROKU_PROCFILE_CNB_VERSION:-0.6.2}"
        "paketobuildpacks/builder:full"
        "paketobuildpacks/builder:base"
        "paketobuildpacks/builder:tiny"
        "paketobuildpacks/run:full-cnb"
        "buildpacksio/lifecycle:${BUILDPACKSIO_LIFECYCLE_VERSION:-0.11.1}"
        "gitlab/gitlab-runner:${GITLAB_RUNNER_VERSION:-alpine-v13.12.0-rc1}"
        "gitlab/gitlab-ce:${GITLAB_VERSION:-14.1.2-ce.0}"
        "jupyterhub/k8s-image-cleaner:${BINDERHUB_IMAGE_CLEANER_VERSION:-0.2.0-n496.h988aca0}"
        "noroutine/k8s-binderhub:${BINDERHUB_VERSION:-0.2.0-n562.h0b4462c}"
        "jupyterhub/k8s-hub:${JUPYTERHUB_VERSION:-1.0.0-beta.1.n004.h8ae542c7}"
        "jupyterhub/k8s-secret-sync:${JUPYTERHUB_SECRET_SYNC_VERSION:-1.0.0-beta.1}"
        "jupyterhub/k8s-network-tools:${JUPYTERHUB_NETWORK_TOOLS_VERSION:-1.0.0-beta.1}"
        "jupyterhub/k8s-image-awaiter:${JUPYTERHUB_IMAGE_AWAITER_VERSION:-1.0.0-beta.1}"
        "jupyterhub/k8s-singleuser-sample:${JUPYTERHUB_SINGLEUSER_SAMPLE_VERSION:-1.0.0-beta.1}"
        "jupyterhub/configurable-http-proxy:${JUPYTERHUB_HTTP_PROXY_VERSION:-4.4.0}"
        "jupyter/repo2docker:${REPO2DOCKER_VERSION:-2021.03.0-15.g73ab48a}"
        "pihole/pihole:${PIHOLE_VERSION:-v5.8.1}"
        "yandex/clickhouse-server:${CLICKHOUSE_VERSION:-21.5.6-alpine}"
        "spoonest/clickhouse-tabix-web-client:${TABIX_VERSION:-stable}"
        "plausible/analytics:${PLAUSIBLE_VERSION:-v1.1.1}"
        "verdaccio/verdaccio:${VERDACCIO_VERSION:-5.0.1}"
        "strapi/strapi:${STRAPI_VERSION:-3.6.3-alpine}"
        "ghost:${GHOST_VERSION:-4.6.4-alpine}"
        "bitnami/ghost:${BITNAMI_GHOST_VERSION:-4.5.0-debian-10-r0}"
        "matomo:${MATOMO_VERSION:-4.3.1}"
        "nocodb/nocodb:${NOCODB_VERSION:-0.9.24}"
        "docker:${DIND_VERSION:-20.10.7-dind}"
        "jupyter/base-notebook:${JUPYTER_VERSION:-016833b15ceb}"
        "jupyter/minimal-notebook:${JUPYTER_VERSION:-016833b15ceb}"
        "jupyter/r-notebook:${JUPYTER_VERSION:-016833b15ceb}"
        "jupyter/scipy-notebook:${JUPYTER_VERSION:-016833b15ceb}"
        "jupyter/tensorflow-notebook:${JUPYTER_VERSION:-016833b15ceb}"
        "jupyter/datascience-notebook:${JUPYTER_VERSION:-016833b15ceb}"
        "jupyter/pyspark-notebook:${JUPYTER_VERSION:-016833b15ceb}"
        "jupyter/all-spark-notebook:${JUPYTER_VERSION:-016833b15ceb}"
        "rocker/shiny:${RSHINY_VERSION:-4.1.0}"
        "caprover/caprover:${CAPROVER_VERSION:-1.9.0}"
        "ghcr.io/mikecao/umami:${UMAMI_VERSION:-postgresql-0653570}"
        "bitnami/spark:${BITNAMI_SPARK_VERSION:-3.1.2-debian-10-r0}"
        "bitnami/prometheus:${BITNAMI_PROMETHEUS_VERSION:-2.27.1-debian-10-r13}"
        "bitnami/prometheus-operator:${BITNAMI_PROMETHEUS_OPERATOR_VERSION:-0.48.1-debian-10-r0}"
        "bitnami/node-exporter:${BITNAMI_NODE_EXPORTER_VERSION:-1.2.2-debian-10-r99}"
        "bitnami/redis:${BITNAMI_REDIS_VERSION:-6.2.4-debian-10-r0}"
        "bitnami/postgresql:${BITNAMI_POSTGRESQL11_VERSION:-11.12.0-debian-10-r20}"
        "bitnami/postgresql:${BITNAMI_POSTGRESQL13_VERSION:-13.3.0-debian-10-r26}"
        "bitnami/postgresql:${BITNAMI_POSTGRESQL14_VERSION:-14.1.0-debian-10-r81}"
        "bitnami/keycloak:${BITNAMI_KEYCLOAK_VERSION:-13.0.1-debian-10-r13}"
        "bitnami/mariadb:${BITNAMI_MARIADB_VERSION:-10.5.10-debian-10-r34}"
        "bitnami/mongodb:${BITNAMI_MONGODB_VERSION:-4.4.7-debian-10-r3}"
        "bitnami/memcached:${BITNAMI_MEMCACHED_VERSION:-1.6.14-debian-10-r42}"
        "bitnami/nginx-ingress-controller:${BITNAMI_NGINX_INGRESS_CONTROLLER_VERSION:-0.47.0-debian-10-r10}"
        "bitnami/nginx:${BITNAMI_NGINX_VERSION:-1.21.0-debian-10-r13}"
        "bitnami/minio:${BITNAMI_MINIO_VERSION:-2021.6.17-debian-10-r5}"
        "bitnami/minio-client:${BITNAMI_MINIO_CLIENT_VERSION:-2021.6.13-debian-10-r12}"
        "bitnami/bitnami-shell:${BITNAMI_SHELL_VERSION:-10-debian-10-r117}"
        "bitnami/metallb-controller:${BITNAMI_METALLB_CONTROLLER_VERSION:-0.10.2-debian-10-r28}"
        "bitnami/metallb-speaker:${BITNAMI_METALLB_SPEAKER_VERSION:-0.10.2-debian-10-r31}"
        "bitnami/grafana:${BITNAMI_GRAFANA_VERSION:-8.0.6-debian-10-r3}"
        "bitnami/consul:${BITNAMI_CONSUL_VERSION:-1.11.4-debian-10-r30}"
        "bitnami/kube-state-metrics:${BITNAMI_KUBE_STATE_METRICS_VERSION:-2.1.1-debian-10-r14}"
        "bitnami/metrics-server:${BITNAMI_METRICS_SERVER_VERSION:-0.5.0-debian-10-r59}"
        "bitnami/kubeapps-dashboard:${BITNAMI_KUBEAPPS_DASHBOARD_VERSION:-2.3.3-scratch-r2}"
        "bitnami/kubeapps-apprepository-controller:${BITNAMI_KUBEAPPS_APPREPOSITORY_CONTROLLER_VERSION:-2.3.3-scratch-r0}"
        "bitnami/kubeapps-asset-syncer:${BITNAMI_KUBEAPPS_ASSET_SYNCER:-2.3.3-scratch-r0}"
        "bitnami/kubeapps-kubeops:${BITNAMI_KUBEAPPS_KUBEOPS_VERSION:-2.3.3-scratch-r0}"
        "bitnami/kubeapps-assetsvc:${BITNAMI_KUBEAPPS_ASSETSVC_VERSION:-2.3.3-scratch-r0}"
        "bitnami/kubeapps-apis:${BITNAMI_KUBEAPPS_APIS_VERSION:-2.4.3-debian-10-r42}"
        "bitnami/kubeapps-pinniped-proxy:${BITNAMI_KUBEAPPS_PINNIPED_PROXY_VERSION:-2.3.3-debian-10-r2}"
        "minio/console:${MINIO_CONSOLE_VERSION:-v0.7.4}"
        "kutt/kutt:${KUTT_VERSION:-2.7.2}"
        "drakkan/sftpgo:${SFTPGO_VERSION:-v2.1.0}"
        "hasura/graphql-engine:${HASURA_VERSION:-v2.0.0-beta.2}"
        "paulbouwer/hello-kubernetes:${HELLO_VERSION:-1.10.0}"
        "stakater/reloader:${RELOADER_VERSION:-v0.0.97}"
        "jimmidyson/configmap-reload:${CONFIGMAP_RELOAD_VERSION:-v0.5.0}"
        "registry:${DOCKER_REGISTRY_VERSION:-2.7.1}"
        "ghcr.io/dexidp/dex:${DEX_VERSION:-v2.30.0}"
        "quay.io/argoproj/argocd:${ARGOCD_VERSION:-v2.1.0-rc2}"
        "redis:${REDIS_VERSION:-6.2.5-buster}"
        "listmonk/listmonk:${LISTMONK_VERSION:-v1.1.0}"
        "registry.gitlab.com/gitlab-org/cluster-integration/auto-build-image:${GITLAB_AUTO_BUILD_VERSION:-v1.0.0}"
        "registry.gitlab.com/gitlab-org/cluster-integration/auto-deploy-image:${GITLAB_AUTO_DEPLOY_VERSION:-v2.6.0}"
        "vaultwarden/server:${VAULTWARDEN_VERSION:-1.23.1}"
        "boky/postfix:${BOKY_POSTFIX_VERSION:-v3.4.0}"
        "cupcakearmy/cryptgeon:${CRYPTGEON_VERSION:-1.4.1}"
        "memcached:${MEMCACHED_VERSION:-1.6.14-alpine3.15}"

        # consul
        "hashicorp/consul:${CONSUL_VERSION:-1.11.4}"
        "hashicorp/consul-k8s-control-plane:${CONSUL_K8S_CP_VERSION:-0.41.1}"
        "envoyproxy/envoy-alpine:${ENVOY_VERSION:-v1.21.1}"
        "hashicorp/vault:${VAULT_VERSION:-1.10.0}"

        # k8s
        "k8s.gcr.io/pause:${K8S_PAUSE_VERSION:-3.7}"
        "k8s.gcr.io/kube-apiserver:${K8S_VERSION:-v1.23.5}"
        "k8s.gcr.io/kube-proxy:${K8S_VERSION:-v1.23.5}"
        "k8s.gcr.io/kube-scheduler:${K8S_VERSION:-v1.23.5}"
        "k8s.gcr.io/kube-controller-manager:${K8S_VERSION:-v1.23.5}"
        "k8s.gcr.io/coredns/coredns:${K8S_COREDNS_VERSION:-v1.8.6}"
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
        # longhorn
        "longhornio/longhorn-manager:v1.2.4"
        "longhornio/csi-node-driver-registrar:v2.3.0"
        "longhornio/longhorn-engine:v1.2.2"
        "longhornio/longhorn-engine:v1.2.3"
        "longhornio/longhorn-engine:v1.2.4"
        "longhornio/longhorn-instance-manager:v1_20220303"
        "longhornio/csi-snapshotter:v3.0.3"
        "longhornio/csi-resizer:v1.2.0"
        "longhornio/csi-provisioner:v2.1.2"
        "longhornio/csi-attacher:v3.2.1"
        "longhornio/longhorn-ui:v1.2.4"
        # vsphere csi/cpi
        "gcr.io/cloud-provider-vsphere/cpi/release/manager:v1.22.6"
        "gcr.io/cloud-provider-vsphere/csi/release/driver:v2.5.1"
        "gcr.io/cloud-provider-vsphere/csi/release/syncer:v2.5.1"
        "k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.5.0"
        "k8s.gcr.io/sig-storage/livenessprobe:v2.6.0"
        "k8s.gcr.io/sig-storage/csi-attacher:v3.4.0"
        "k8s.gcr.io/sig-storage/csi-resizer:v1.4.0"
        "k8s.gcr.io/sig-storage/csi-provisioner:v3.1.0"
        # certmanager shit
        "vstadtmueller/cert-manager-webhook-powerdns:main"
    )

    local target_registry=${1:-${DOCKER_HUB:-cr.nrtn.dev}}

    # For dependabot
    for image in ${images[@]}; do
        echo "# $(get_name ${image})"
        echo "FROM ${image}"
        echo "# $(get_name ${image})"
        echo
    done

    for image in ${images[@]}; do
        printf "\nMigrating %s/%s:%s to %s\n`line`\n" \
            $(get_registry $image) $(get_name $image) $(get_tag $image) \
            ${target_registry}
        migrate_image ${image} ${target_registry}
    done
}

_main() {
    local source_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    source ${source_dir}/env.sh
    
    import_images
}

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || _main "${@:-}"

# End of file
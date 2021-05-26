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
        "${DEPLOYER_BASE:-ubuntu:focal}"
        "${BUILDER_BASE:-debian:10-slim}"
        "${POWERDNS_BASE:-debian:10-slim}"
        "${GATSBY_BASE:-alpine:edge}"
        "${GATSBY_BUILD_BASE:-node:14-buster}"
        "${LATEX_BASE:-ubuntu:focal}"
        "php:7.4-apache"
        "alpine:3.12.1"
        "golang:1.15.3-alpine3.12"
        "traefik:${TRAEFIK_VERSION:-latest}"
        "jekyll/jekyll:${JEKYLL_VERSION:-latest}"
        "squidfunk/mkdocs-material:${MKDOCS_VERSION:-latest}"
        "freeradius/freeradius-server:${FREERADIUS_VERSION:-latest}"
        "quay.io/keycloak/keycloak:${KEYCLOAK_VERSION:-11.0.2}"
        "postgres:${POSTGRES_VERSION:-13.0}"
        "atlassian/jira-software:${JIRA_VERSION:-8.13.0}"
        "tvial/docker-mailserver:${MAILSERVER_VERSION:-release-v7.1.0}"
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
        "confluentinc/cp-zookeeper:${KAFKA_ZOOKEEPER_VERSION:-6.1.1}"
        "confluentinc/cp-server:${KAFKA_SERVER_VERSION:-6.1.1}"
        "confluentinc/cp-schema-registry:${KAFKA_SCHEMA_REGISTRY_VERSION:-6.1.1}"
        "cnfldemos/cp-server-connect-datagen:${KAFKA_SERVER_CONNECT_DATAGEN_VERSION:-0.4.0-6.1.0}"
        "confluentinc/cp-enterprise-control-center:${KAFKA_ENTERPRISE_CONTROL_CENTER_VERSION:-6.1.1}"
        "confluentinc/cp-ksqldb-server:${KAFKA_KSQLDB_SERVER_VERSION:-6.1.1}"
        "confluentinc/cp-ksqldb-cli:${KAFKA_KSQLDB_CLI_VERSION:-6.1.1}"
        "confluentinc/cp-kafka-rest:${KAFKA_REST_VERSION:-6.1.1}"
        "confluentinc/ksqldb-examples:${KAFKA_KSQLDB_EXAMPLES_VERSION:-6.1.1}"
        "quay.io/oauth2-proxy/oauth2-proxy:${OAUTH2_PROXY_VERSION:-v7.1.2-amd64}"
        "heroku/heroku:20-build"
        "heroku/heroku:20"
        "paketobuildpacks/builder:full"
        "paketobuildpacks/builder:base"
        "paketobuildpacks/builder:tiny"
        "paketobuildpacks/run:full-cnb"
        "buildpacksio/lifecycle:${BUILDPACKSIO_LIFECYCLE_VERSION:-0.11.1}"
        "gitlab/gitlab-runner:${GITLAB_RUNNER_VERSION:-alpine-v13.12.0-rc1}"
        "jupyterhub/k8s-image-cleaner:${BINDERHUB_IMAGE_CLEANDER_VERSION:-0.2.0-n496.h988aca0}"
        "jupyterhub/k8s-binderhub:${BINDERHUB_VERSION:-0.2.0-n562.h0b4462c}"
    )

    local target_registry=${1:-${DOCKER_HUB:-cr.nrtn.dev}}

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
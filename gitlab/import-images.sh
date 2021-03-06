#!/bin/bash -eux

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

    if [[ "$?" != 0 ]]; then    
        docker pull ${source_registry}/${image_name}:${image_tag}
        docker tag ${source_registry}/${image_name}:${image_tag} ${target_registry}/${image_name}:${image_tag}
        docker push ${target_registry}/${image_name}:${image_tag}
    fi
    set -e
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
        "docker.elastic.co/logstash/logstash:${LOGSTASH_VERSION:-latest}"
        "docker.elastic.co/kibana/kibana:${KIBANA_VERSION:-latest}"
        "alerta/alerta-web:${ALERTA_VERSION:-latest}"
        "mongo:${MONGO_VERSION:-latest}"
    )

    local target_registry=${1:-${DOCKER_HUB:-nexus.noroutine.me:5000}}

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
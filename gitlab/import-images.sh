#!/usr/bin/env bash

import_images() {
    declare -a images=(
        "debian:${DEBIAN_VERSION:-11.0-slim}:::prepend_name=library/"
        "ubuntu:${UBUNTU_NOBLE_VERSION:-focal-20240212}:::prepend_name=library/"
        "ubuntu:${UBUNTU_JAMMY_VERSION:-jammy-20220315}:::prepend_name=library/"
        "ubuntu:${UBUNTU_FOCAL_VERSION:-focal-20210723}:::prepend_name=library/"
        "alpine:${ALPINE_VERSION:-3.14.0}:::prepend_name=library/"
        "busybox:${BUSYBOX_VERSION:-1.34.1}:::prepend_name=library/"
        "gcr.io/distroless/static-${DISTROLESS_VERSION:-debian11}"
        "gcr.io/distroless/base-${DISTROLESS_VERSION:-debian11}"
        "gcr.io/distroless/java11-${DISTROLESS_VERSION:-debian11}"
        "gcr.io/distroless/java17-${DISTROLESS_VERSION:-debian11}"
        "gcr.io/distroless/cc-${DISTROLESS_VERSION:-debian11}"
        "gcr.io/distroless/nodejs-${DISTROLESS_VERSION:-debian11}"
        "buildpack-deps:${BUILDPACK_DEPS_BIONIC_VERSION:-bionic@sha256:1ae2e168c8cc4408fdf7cb40244643b99d10757f36391eee844834347de3c15c}:::prepend_name=library/"
        "buildpack-deps:${BUILDPACK_DEPS_FOCAL_VERSION:-focal@sha256:eecbd661c4983df91059018d67c0d7203c68c1eeac036e6a479c3df94483ffba}:::prepend_name=library/"
        "buildpack-deps:${BUILDPACK_DEPS_JAMMY_VERSION:-jammy@sha256:e93e88c6e97ffb6a315182db7d606dcb161714db7b2961a4efe727d39c165e1a}:::prepend_name=library/"
        "php:${PHP_VERSION:-8.1.0-apache}:::prepend_name=library/"
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
        "atlassian/jira-software:${JIRA_VERSION:-8.13.0}"
        "nextcloud:${NEXTCLOUD_VERSION:-20.0.0-fpm-alpine}:::prepend_name=library/"
        "haproxytech/haproxy-debian:${HAPROXY_VERSION:-2.3.4}"
        "minio/minio:${MINIO_VERSION:-RELEASE.2021-02-07T01-31-02Z}"
        "quay.io/coreos/etcd:${ETCD_VERSION:-latest}"
        "quay.io/prometheus/prometheus:${PROMETHEUS_VERSION:-latest}"
        "quay.io/prometheus/alertmanager:${ALERTMANAGER_VERSION:-latest}"
        "quay.io/prometheus/node-exporter:${NODE_EXPORTER_VERSION:-latest}"
        "quay.io/prometheus/consul-exporter:${CONSUL_EXPORTER_VERSION:-latest}"
        "quay.io/prometheus/blackbox-exporter:${BLACKBOX_EXPORTER_VERSION:-latest}"
        "quay.io/prometheus/snmp-exporter:${SNMP_EXPORTER_VERSION:-latest}"
        "quay.io/prometheus/pushgateway:${PUSHGATEWAY_VERSION:-latest}"
        "quay.io/prometheus-operator/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION:-latest}"
        "quay.io/prometheus-operator/prometheus-config-reloader:${PROMETHEUS_OPERATOR_VERSION:-latest}"
        "grafana/grafana:${GRAFANA_VERSION:-8.4.5}"
        "grafana/loki:${LOKI_VERSION:-2.5.0}"
        "grafana/loki-canary:${LOKI_VERSION:-2.5.0}"
        "grafana/promtail:${PROMTAIL_VERSION:-2.5.0}"
        "nginxinc/nginx-unprivileged:${LOKI_GATEWAY_NGINX_VERSION:-1.23.3-alpine-slim}"
        "nginxinc/nginx-unprivileged:${NGINX_VERSION:-1.23.3-alpine-slim}"
        "httpd:${HTTPD_VERSION:-2.4.55-alpine}:::prepend_name=library/"
        "tomcat:${TOMCAT_VERSION:-10.1.7-jdk17-temurin-jammy}:::prepend_name=library/"
        "quay.io/m3db/m3coordinator:${M3COORDINATOR_VERSION:-latest}"
        "quay.io/m3db/m3dbnode:${M3DBNODE_VERSION:-latest}"
        "braedon/prometheus-es-exporter:${PROMETHEUS_ES_EXPORTER_VERSION:-latest}"
        "ribbybibby/ssl-exporter:${SSL_EXPORTER_VERSION:-latest}"
        "gcr.io/cadvisor/cadvisor:${CADVISOR_VERSION:-latest}"
        "ghcr.io/prymitive/karma:${KARMA_VERSION:-latest}"
        "quay.io/cortexproject/cortex:${CORTEX_VERSION:-latest}"
        "docker.elastic.co/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION:-latest}:::prepend_name=elastic/"
        "docker.elastic.co/logstash/logstash:${LOGSTASH_VERSION:-latest}:::prepend_name=elastic/"
        "docker.elastic.co/kibana/kibana:${KIBANA_VERSION:-latest}:::prepend_name=elastic/"
        "alerta/alerta-web:${ALERTA_VERSION:-latest}"
        "mongo:${MONGO_VERSION:-latest}:::prepend_name=library/"
        "wordpress:${WORDPRESS_VERSION:-5.7.0-apache}:::prepend_name=library/"
        "dpage/pgadmin4:${PGADMIN_VERSION:-5.0}"
        "adminer:${ADMINER_VERSION:-4.8.1-standalone}:::prepend_name=library/"
        "mysql:${MYSQL_VERSION}:::prepend_name=library/"
        "mariadb:${MARIADB_VERSION}:::prepend_name=library/"
        "mccutchen/go-httpbin:${HTTPBIN_VERSION}"
        "quay.io/oauth2-proxy/oauth2-proxy:${OAUTH2_PROXY_VERSION:-v7.1.2-amd64}"
        "heroku/heroku:20-build"
        "heroku/heroku:20"
        "heroku/heroku:22-build"
        "heroku/heroku:22"
        "heroku/heroku:22-cnb-build"
        "heroku/heroku:22-cnb"
        "heroku/heroku:24-build"
        "heroku/heroku:24"
        "heroku/buildpack-procfile:${HEROKU_PROCFILE_CNB_VERSION:-0.6.2}"
        "paketobuildpacks/builder:full"
        "paketobuildpacks/builder:base"
        "paketobuildpacks/builder:tiny"
        "paketobuildpacks/run:full-cnb"
        "buildpacksio/lifecycle:${BUILDPACKSIO_LIFECYCLE_VERSION:-0.11.1}"
        "gitlab/gitlab-runner:${GITLAB_RUNNER_VERSION:-alpine-v13.12.0-rc1}"
        "gitlab/gitlab-ce:${GITLAB_VERSION:-14.1.2-ce.0}"
        "registry.gitlab.com/gitlab-org/gitlab-runner/gitlab-runner-helper:${GITLAB_RUNNER_HELPER_VERSION:-x86_64-v16.10.0}"
        "registry.gitlab.com/gitlab-org/cluster-integration/auto-build-image:${GITLAB_AUTO_BUILD_VERSION:-v1.0.0}"
        "registry.gitlab.com/gitlab-org/cluster-integration/auto-deploy-image:${GITLAB_AUTO_DEPLOY_VERSION:-v2.6.0}"
        "registry.gitlab.com/gitlab-org/cluster-integration/gitlab-agent/agentk:${GITLAB_AGENTK_VERSION:-v15.0.0}"
        "registry.gitlab.com/gitlab-org/cluster-integration/cluster-applications:${GITLAB_CLUSTER_APPLICATIONS_VERSION:-v1.1.0}"
        "summerwind/actions-runner-controller:${ACTIONS_RUNNER_CONTROLLER_VERSION:-v0.23.0}"
        "summerwind/actions-runner:${ACTIONS_RUNNER_IMAGE_VERSION:-v2.291.1-ubuntu20.04}"
        "summerwind/actions-runner-dind:${ACTIONS_RUNNER_IMAGE_VERSION:-v2.291.1-ubuntu20.04}"
        "quay.io/brancz/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION:-v0.12.0}"
        "jupyterhub/k8s-image-cleaner:${BINDERHUB_IMAGE_CLEANER_VERSION:-0.2.0-n496.h988aca0}"
        "noroutine/k8s-binderhub:${BINDERHUB_VERSION:-0.2.0-n562.h0b4462c}"
        "jupyterhub/k8s-hub:${JUPYTERHUB_VERSION:-1.0.0-beta.1.n004.h8ae542c7}"
        "jupyterhub/k8s-secret-sync:${JUPYTERHUB_SECRET_SYNC_VERSION:-1.0.0-beta.1}"
        "jupyterhub/k8s-network-tools:${JUPYTERHUB_NETWORK_TOOLS_VERSION:-1.0.0-beta.1}"
        "jupyterhub/k8s-image-awaiter:${JUPYTERHUB_IMAGE_AWAITER_VERSION:-1.0.0-beta.1}"
        "jupyterhub/k8s-singleuser-sample:${JUPYTERHUB_SINGLEUSER_SAMPLE_VERSION:-1.0.0-beta.1}"
        "jupyterhub/configurable-http-proxy:${JUPYTERHUB_HTTP_PROXY_VERSION:-4.4.0}"
        "registry.k8s.io/kube-scheduler:${JUPYTERHUB_SCHEDULER_VERSION:-v1.25.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/pause:${JUPYTERHUB_PAUSE_VERSION:-3.7}:::prepend_name=kubernetes/"
        "quay.io/jupyterhub/repo2docker:${REPO2DOCKER_VERSION:-2021.03.0-15.g73ab48a}"
        "pihole/pihole:${PIHOLE_VERSION:-v5.8.1}"
        "yandex/clickhouse-server:${CLICKHOUSE_VERSION:-21.5.6-alpine}"
        "spoonest/clickhouse-tabix-web-client:${TABIX_VERSION:-stable}"
        "plausible/analytics:${PLAUSIBLE_VERSION:-v1.1.1}"
        "verdaccio/verdaccio:${VERDACCIO_VERSION:-5.0.1}"
        "strapi/strapi:${STRAPI_VERSION:-3.6.3-alpine}"
        "ghost:${GHOST_VERSION:-4.6.4-alpine}:::prepend_name=library/"
        "bitnami/ghost:${BITNAMI_GHOST_VERSION:-4.5.0-debian-10-r0}"
        "matomo:${MATOMO_VERSION:-4.3.1}:::prepend_name=library/"
        "nocodb/nocodb:${NOCODB_VERSION:-0.9.24}"
        "metabase/metabase:${METABASE_VERSION:-v0.43.0}"
        "docker:${DIND_VERSION:-20.10.7-dind}:::prepend_name=library/"
        "quay.io/podman/stable:${PINK_VERSION:-v4.4.2}"
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
        "bitnami/blackbox-exporter:${BITNAMI_BLACKBOX_EXPORTER_VERSION:-0.21.0-debian-11-r7}"
        "bitnami/postgres-exporter:${BITNAMI_POSTGRES_EXPORTER_VERSION:-0.10.1-debian-10-r131}"
        "bitnami/redis:${BITNAMI_REDIS_VERSION:-6.2.4-debian-10-r0}"
        "bitnami/redis-exporter:${BITNAMI_REDIS_EXPORTER_VERSION:-1.43.1-debian-11-r0}"
        "bitnami/postgresql:${BITNAMI_POSTGRESQL10_VERSION:-10.23.0-debian-11-r0}"
        "bitnami/postgresql:${BITNAMI_POSTGRESQL11_VERSION:-11.12.0-debian-10-r20}"
        "bitnami/postgresql:${BITNAMI_POSTGRESQL12_VERSION:-12.11.0-debian-10-r12}"
        "bitnami/postgresql:${BITNAMI_POSTGRESQL13_VERSION:-13.3.0-debian-10-r26}"
        "bitnami/postgresql:${BITNAMI_POSTGRESQL14_VERSION:-14.1.0-debian-10-r81}"
        "bitnami/postgresql:${BITNAMI_POSTGRESQL15_VERSION:-15.0.0-debian-11-r0}"
        "bitnami/postgresql:${BITNAMI_POSTGRESQL16_VERSION:-16.0.0-debian-11-r0}"
        "bitnami/tomcat:${BITNAMI_TOMCAT_VERSION:-10.1.7-debian-11-r8}"
        "bitnami/jmx-exporter:${BITNAMI_JMX_EXPORTER_VERSION:-0.18.0-debian-11-r10}"
        "bitnami/keycloak:${BITNAMI_KEYCLOAK_VERSION:-13.0.1-debian-10-r13}"
        "bitnami/keycloak-config-cli:${BITNAMI_KEYCLOAK_CONFIG_CLI_VERSION:-5.5.0-debian-11-r11}"
        "bitnami/mariadb:${BITNAMI_MARIADB_VERSION:-10.5.10-debian-10-r34}"
        "bitnami/mongodb:${BITNAMI_MONGODB_VERSION:-4.4.7-debian-10-r3}"
        "bitnami/memcached:${BITNAMI_MEMCACHED_VERSION:-1.6.14-debian-10-r42}"
        "bitnami/nginx-ingress-controller:${BITNAMI_NGINX_INGRESS_CONTROLLER_VERSION:-0.47.0-debian-10-r10}"
        "bitnami/nginx:${BITNAMI_NGINX_VERSION:-1.21.0-debian-10-r13}"
        "bitnami/minio:${BITNAMI_MINIO_VERSION:-2021.6.17-debian-10-r5}"
        "bitnami/minio-client:${BITNAMI_MINIO_CLIENT_VERSION:-2021.6.13-debian-10-r12}"
        "bitnami/os-shell:${BITNAMI_SHELL_VERSION:-10-debian-10-r117}"
        "bitnami/metallb-controller:${BITNAMI_METALLB_CONTROLLER_VERSION:-0.10.2-debian-10-r28}"
        "bitnami/metallb-speaker:${BITNAMI_METALLB_SPEAKER_VERSION:-0.10.2-debian-10-r31}"
        "bitnami/grafana:${BITNAMI_GRAFANA_VERSION:-8.0.6-debian-10-r3}"
        "bitnami/grafana-image-renderer:${BITNAMI_GRAFANA_IMAGE_RENDERER_VERSION:-3.4.2-debian-10-r43}"
        "bitnami/consul:${BITNAMI_CONSUL_VERSION:-1.11.4-debian-10-r30}"
        "bitnami/nats:${BITNAMI_NATS_VERSION:-2.7.4-debian-10-r17}"
        "bitnami/kube-state-metrics:${BITNAMI_KUBE_STATE_METRICS_VERSION:-2.1.1-debian-10-r14}"
        "bitnami/metrics-server:${BITNAMI_METRICS_SERVER_VERSION:-0.5.0-debian-10-r59}"
        "bitnami/kubeapps-dashboard:${BITNAMI_KUBEAPPS_DASHBOARD_VERSION:-2.3.3-scratch-r2}"
        "bitnami/kubeapps-apprepository-controller:${BITNAMI_KUBEAPPS_APPREPOSITORY_CONTROLLER_VERSION:-2.3.3-scratch-r0}"
        "bitnami/kubeapps-asset-syncer:${BITNAMI_KUBEAPPS_ASSET_SYNCER:-2.3.3-scratch-r0}"
        "bitnami/kubeapps-apis:${BITNAMI_KUBEAPPS_APIS_VERSION:-2.4.3-debian-10-r42}"
        "bitnami/kubeapps-pinniped-proxy:${BITNAMI_KUBEAPPS_PINNIPED_PROXY_VERSION:-2.3.3-debian-10-r2}"
        "bitnami/kube-rbac-proxy:${BITNAMI_KUBE_RBAC_PROXY_VERSION:-0.12.0-scratch-r2}"
        "bitnami/openldap:${BITNAMI_OPENLDAP_VERSION:-2.5.13-debian-11-r0}"
        "bitnami/sealed-secrets-controller:${BITNAMI_SEALED_SECRETS_CONTROLLER_VERSION:-v0.17.2}"
        "bitnami/trivy:${BITNAMI_TRIVY_VERSION:-0.33.0-debian-11-r0}"
        "bitnami/kubectl:${BITNAMI_KUBECTL_VERSION:-1.26.1-debian-11-r9}"
        "bitnami/harbor-adapter-trivy:${BITNAMI_HARBOR_VERSION:-2.10.1-debian-12-r1}"
        "bitnami/harbor-core:${BITNAMI_HARBOR_VERSION:-2.10.1-debian-12-r1}"
        "bitnami/harbor-exporter:${BITNAMI_HARBOR_VERSION:-2.10.1-debian-12-r1}"
        "bitnami/harbor-jobservice:${BITNAMI_HARBOR_VERSION:-2.10.1-debian-12-r1}"
        "bitnami/harbor-portal:${BITNAMI_HARBOR_VERSION:-2.10.1-debian-12-r1}"
        "bitnami/harbor-registry:${BITNAMI_HARBOR_VERSION:-2.10.1-debian-12-r1}"
        "bitnami/harbor-registryctl:${BITNAMI_HARBOR_VERSION:-2.10.1-debian-12-r1}"
        "goharbor/harbor-portal:${HARBOR_VERSION:-v2.10.1}"
        "goharbor/harbor-core:${HARBOR_VERSION:-v2.10.1}"
        "goharbor/harbor-jobservice:${HARBOR_VERSION:-v2.10.1}"
        "goharbor/registry-photon:${HARBOR_VERSION:-v2.10.1}"
        "goharbor/harbor-registryctl:${HARBOR_VERSION:-v2.10.1}"
        "goharbor/harbor-db:${HARBOR_VERSION:-v2.10.1}"
        "goharbor/harbor-exporter:${HARBOR_VERSION:-v2.10.1}"
        "goharbor/redis-photon:${HARBOR_VERSION:-v2.10.1}"
        "goharbor/trivy-adapter-photon:${HARBOR_VERSION:-v2.10.1}"
        "goharbor/nginx-photon:${HARBOR_VERSION:-v2.10.1}"
        "aquasec/trivy:${TRIVY_VERSION:-0.33.0}"
        "ghcr.io/external-secrets/external-secrets:${EXTERNAL_SECRETS_VERSION:-v0.5.3}"
        "minio/console:${MINIO_CONSOLE_VERSION:-v0.7.4}"
        "kutt/kutt:${KUTT_VERSION:-2.7.2}"
        "drakkan/sftpgo:${SFTPGO_VERSION:-v2.1.0}"
        "hasura/graphql-engine:${HASURA_GRAPHQL_VERSION:-v2.0.0-beta.2}"
        "paulbouwer/hello-kubernetes:${HELLO_VERSION:-1.10.0}"
        "stakater/reloader:${RELOADER_VERSION:-v0.0.97}"
        "jimmidyson/configmap-reload:${CONFIGMAP_RELOAD_VERSION:-v0.5.0}"
        "registry:${DOCKER_REGISTRY_VERSION:-2.7.1}:::prepend_name=library/"
        "ghcr.io/dexidp/dex:${DEX_VERSION:-v2.30.0}"
        "quay.io/argoproj/argocd:${ARGOCD_VERSION:-v2.1.0-rc2}"
        "quay.io/argoproj/argocd-applicationset:${ARGOCD_APPLICATIONSET_VERSION:-v0.4.1}"
        "quay.io/argoproj/argo-events:${ARGO_EVENTS_VERSION:-v1.7.6}"
        "quay.io/argoproj/argocli:${ARGO_WORKFLOWS_VERSION:-v3.4.5}"
        "quay.io/argoproj/workflow-controller:${ARGO_WORKFLOWS_VERSION:-v3.4.5}"
        "quay.io/argoproj/argoexec:${ARGO_WORKFLOWS_VERSION:-v3.4.5}"
        "redis:${REDIS_VERSION:-6.2.5-buster}:::prepend_name=library/"
        "listmonk/listmonk:${LISTMONK_VERSION:-v1.1.0}"
        "vaultwarden/server:${VAULTWARDEN_VERSION:-1.23.1}"
        "boky/postfix:${BOKY_POSTFIX_VERSION:-v3.4.0}"
        "cupcakearmy/cryptgeon:${CRYPTGEON_VERSION:-1.4.1}"
        "memcached:${MEMCACHED_VERSION:-1.6.14-alpine3.15}:::prepend_name=library/"
        "connecteverything/nats-operator:${NATS_OPERATOR_VERSION:-0.7.4}"
        "nats:${NATS_VERSION:-2.7.4-alpine3.15}:::prepend_name=library/"
        "natsio/prometheus-nats-exporter:${NATS_EXPORTER_VERSION:-0.10.1}"
        "natsio/nats-server-config-reloader:${NATS_SERVER_CONFIG_RELOADER:-0.10.1}"
        "masipcat/wireguard-go:${WIREGUARD_VERSION:-0.0.20220316}"
        "eclipse-mosquitto:${MOSQUITTO_VERSION:-2.0.14-openssl}:::prepend_name=library/"
        "sapcc/mosquitto-exporter:${MOSQUITTO_EXPORTER_VERSION:-0.8.0}"
        "caddy:${CADDY_VERSION:-2.5.1}:::prepend_name=library/"
        "quay.io/outline/shadowbox:${SHADOWBOX_VERSION:-stable}"
        "gcr.io/kaniko-project/executor:${KANIKO_VERSION:-v1.8.1}"
        "quay.io/iovisor/bpftrace:${BPFTRACE_VERSION:-v0.15.0}"
        "pryorda/vmware_exporter:${VMWARE_EXPORTER_VERSION:-v0.18.3}"
        "azul/zulu-openjdk:${JDK_ZULU_VERSION:-18.0.1-18.30.11}"
        "eclipse-temurin:${JDK_TEMURIN_VERSION:-20_36-jdk-jammy}:::prepend_name=library/"
        "elastic/eck-operator:${ECK_OPERATOR_VERSION:-2.3.0}"
        "louislam/uptime-kuma:${UPTIME_KUMA_VERSION:-1.17.1-alpine}"
        "hadolint/hadolint:${HADOLINT_VERSION:-v2.10.0-beta}"
        "outlinewiki/outline:${OUTLINE_VERSION:-0.66.2}"
        "syncthing/syncthing:${SYNCTHING_VERSION:-1.22.1}"
        "syncthing/discosrv:${SYNCTHING_VERSION:-1.22.1}"
        "syncthing/relaysrv:${SYNCTHING_VERSION:-1.22.1}"
        "jellyfin/jellyfin:${JELLYFIN_VERSION:-10.8.7}"
        "haveagitgat/tdarr:${TDARR_VERSION:-2.200.25}"
        "haveagitgat/tdarr_node:${TDARR_VERSION:-2.200.25}"
        "gravitl/netmaker:${NETMAKER_VERSION:-v0.16.3}"
        "gravitl/netmaker-ui:${NETMAKER_UI_VERSION:-v0.16.3}"
        "kmb32123/youtube-dl-server:${YOUTUBE_DL_SERVER_VERSION:-2.0}"
        "puppet/puppetserver:${PUPPETSERVER_VERSION:-7.9.2}"
        "puppet/puppetdb:${PUPPETDB_VERSION:-7.10.0}"
        "ghcr.io/voxpupuli/puppetboard:${PUPPETBOARD_VERSION:-4.2.0}"
        "puppet/r10k:${R10K_VERSION:-3.15.2}"
        "restic/restic:${RESTIC_VERSION:-0.14.0}"
        "registry.k8s.io/coredns/coredns:${COREDNS_VERSION:-v1.8.6}"
        "yugabytedb/yugabyte:${YUGABYTE_VERSION:-2.17.0.0-b24}"
        "antelle/keeweb:${KEEWEB_VERSION:-1.18.7}"
        "wiretrustee/dashboard:${NETBIRD_DASHBOARD_VERSION:-v1.6.0}"
        "netbirdio/signal:${NETBIRD_SIGNAL_VERSION:-0.12.0}"
        "netbirdio/management:${NETBIRD_MANAGEMENT_VERSION:-0.12.0}"
        "coturn/coturn:${COTURN_VERSION:-4.6.1}"
        "firezone/firezone:${FIREZONE_VERSION:-0.7.6}"
        "jenkins/jenkins:${JENKINS_VERSION:-2.389-jdk17}"
        "jenkins/agent:${JENKINS_AGENT_VERSION:-3085.vc4c6977c075a-5-jdk17}"
        "quay.io/jenkins-kubernetes-operator/operator:${JENKINS_OPERATOR_VERSION:-v0.8.0-beta2}"
        "netboxcommunity/netbox:${NETBOX_VERSION:-v3.4.5}"
        "kubernetesui/dashboard:${K8S_DASHBOARD_VERSION:-v2.7.0}"
        "kubernetesui/dashboard-api:${K8S_DASHBOARD_API_VERSION:-v1.0.0}"
        "kubernetesui/dashboard-web:${K8S_DASHBOARD_WEB_VERSION:-v1.0.0}"
        "kubernetesui/metrics-scraper:${K8S_DASHBOARD_METRICS_SCRAPER_VERSION:-v1.0.9}"
        "locustio/locust:${LOCUST_VERSION:-2.15.1}"
        "postgrest/postgrest:${POSTGREST_VERSION:-v10.2.0.20230209}"
        "mcr.microsoft.com/oss/azure/workload-identity/webhook:${AZURE_WORKLOAD_IDENTITY_VERSION:-v1.1.0}:::prepend_name=microsoft/"
        "mcr.microsoft.com/k8s/azureserviceoperator:${AZURE_SERVICE_OPERATOR_VERSION:-v2.2.0}:::prepend_name=microsoft/"
        "guacamole/guacamole:${GUACAMOLE_VERSION:-1.5.3}"
        "guacamole/guacd:${GUACAMOLE_VERSION:-1.5.3}"
        "quay.io/cephcsi/cephcsi:${CEPHCSI_VERSION:-v3.10.2}"

        # Velero
        "velero/velero:${VELERO_VERSION:-v1.10.1}"
        "velero/velero-plugin-for-csi:${VELERO_PLUGIN_CSI_VERSION:-v0.4.1}"
        "velero/velero-plugin-for-aws:${VELERO_PLUGIN_AWS_VERSION:-v1.6.1}"
        "velero/velero-plugin-for-gcp:${VELERO_PLUGIN_GCP_VERSION:-v1.6.1}"
        "velero/velero-plugin-for-microsoft-azure:${VELERO_PLUGIN_AZURE_VERSION:-v1.6.1}"
        "vsphereveleroplugin/velero-plugin-for-vsphere:${VELERO_PLUGIN_VSPHERE_VERSION:-v1.4.2}"
        "vsphereveleroplugin/backup-driver:${VELERO_PLUGIN_VSPHERE_VERSION:-v1.4.2}"
        "vsphereveleroplugin/data-manager-for-plugin:${VELERO_PLUGIN_VSPHERE_VERSION:-v1.4.2}"
        "velero/velero-restic-restore-helper:${VELERO_RESTIC_RESTORE_HELPER_VERSION:-v1.9.5}"
        "bitnami/kubectl:${VELERO_KUBECTL_VERSION:-1.26.1-debian-11-r9}"

        # Airflow
        "apache/airflow:${AIRFLOW_VERSION:-2.3.4-python3.10}"
        "registry.k8s.io/git-sync/git-sync:${GIT_SYNC_VERSION:-v3.6.1}"

        # KEDA
        "ghcr.io/kedacore/keda:${KEDA_VERSION:-2.8.0}"
        "ghcr.io/kedacore/keda-metrics-apiserver:${KEDA_VERSION:-2.8.0}"

        # cert-manager
        "quay.io/jetstack/cert-manager-controller:${CERT_MANAGER_VERSION:-v1.8.0}"
        "quay.io/jetstack/cert-manager-cainjector:${CERT_MANAGER_VERSION:-v1.8.0}"
        "quay.io/jetstack/cert-manager-webhook:${CERT_MANAGER_VERSION:-v1.8.0}"
        "quay.io/jetstack/cert-manager-ctl:${CERT_MANAGER_VERSION:-v1.8.0}"
        "quay.io/jetstack/cert-manager-csi-driver:${CERT_MANAGER_CSI_DRIVER_VERSION:-v0.3.0}"
        "zachomedia/cert-manager-webhook-pdns:${CERT_MANAGER_WEBHOOK_PDNS_VERSION:-v2.0.1}"
        "vstadtmueller/cert-manager-webhook-powerdns:${CERT_MANAGER_WEBHOOK_POWERDNS_VERSION:-main}"

        # consul
        "hashicorp/consul:${CONSUL_VERSION:-1.11.4}"
        "hashicorp/consul-k8s-control-plane:${CONSUL_K8S_CP_VERSION:-0.41.1}"
        "envoyproxy/envoy-alpine:${ENVOY_VERSION:-v1.21.1}"

        # vault
        "hashicorp/vault:${VAULT_VERSION:-1.10.0}"
        "hashicorp/vault-k8s:${VAULT_K8S_VERSION:-0.15.0}"
        "hashicorp/vault-csi-provider:${VAULT_CSI_PROVIDER_VERSION:-1.1.0}"

        # kafka
        "quay.io/strimzi/operator:${STRIMZI_OPERATOR_VERSION:-0.28.0}"
        "quay.io/strimzi/kafka:${STRIMZI_OPERATOR_VERSION:-0.28.0}-kafka-${STRIMZI_KAFKA_VERSION:-3.1.0}"

        # k8s
        "registry.k8s.io/pause:${K8S_PAUSE_VERSION:-3.7}:::prepend_name=kubernetes/"
        "registry.k8s.io/coredns/coredns:${K8S_COREDNS_VERSION:-v1.8.6}"

        "registry.k8s.io/kube-apiserver:${K8S_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_VERSION:-v1.23.5}:::prepend_name=kubernetes/"

        # k8s 1.28.x
        "registry.k8s.io/kube-apiserver:${K8S_128_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_128_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_128_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_128_VERSION:-v1.23.5}:::prepend_name=kubernetes/"

        # k8s 1.27.x
        "registry.k8s.io/kube-apiserver:${K8S_127_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_127_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_127_VERSION:-v1.23.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_127_VERSION:-v1.23.5}:::prepend_name=kubernetes/"

        # k8s 1.26.x
        "registry.k8s.io/kube-apiserver:${K8S_126_VERSION:-v1.26.3}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_126_VERSION:-v1.26.3}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_126_VERSION:-v1.26.3}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_126_VERSION:-v1.26.3}:::prepend_name=kubernetes/"

        # k8s 1.25.x
        "registry.k8s.io/kube-apiserver:${K8S_125_VERSION:-v1.25.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_125_VERSION:-v1.25.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_125_VERSION:-v1.25.5}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_125_VERSION:-v1.25.5}:::prepend_name=kubernetes/"

        # k8s 1.24.x
        "registry.k8s.io/kube-apiserver:${K8S_124_VERSION:-v1.24.7}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_124_VERSION:-v1.24.7}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_124_VERSION:-v1.24.7}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_124_VERSION:-v1.24.7}:::prepend_name=kubernetes/"

        # k8s 1.23.x
        "registry.k8s.io/kube-apiserver:${K8S_123_VERSION:-v1.24.7}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-proxy:${K8S_123_VERSION:-v1.24.7}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-scheduler:${K8S_123_VERSION:-v1.24.7}:::prepend_name=kubernetes/"
        "registry.k8s.io/kube-controller-manager:${K8S_123_VERSION:-v1.24.7}:::prepend_name=kubernetes/"

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

        # NFD
        "registry.k8s.io/nfd/node-feature-discovery:${K8S_NFD_VERSION:-v0.13.3}"

        # longhorn
        "longhornio/longhorn-manager:${LONGHORN_VERSION:-v1.5.1}"
        "longhornio/longhorn-ui:${LONGHORN_VERSION:-v1.5.1}"
        "longhornio/longhorn-engine:${LONGHORN_VERSION:-v1.5.1}"
        "longhornio/longhorn-instance-manager:${LONGHORN_VERSION:-v1.5.1}"
        "longhornio/longhorn-share-manager:${LONGHORN_VERSION:-v1.5.1}"
        "longhornio/backing-image-manager:${LONGHORN_VERSION:-v1.5.1}"
        "longhornio/csi-node-driver-registrar:${LONGHORN_CSI_NODE_DRIVER_REGISTRAR_VERSION:-v2.7.0}"
        "longhornio/csi-snapshotter:${LONGHORN_CSI_SNAPSHOTTER_VERSION:-v6.2.1}"
        "longhornio/csi-resizer:${LONGHORN_CSI_RESIZER_VERSION:-v1.7.0}"
        "longhornio/csi-provisioner:${LONGHORN_CSI_PROVISIONER_VERSION:-v3.4.1}"
        "longhornio/csi-attacher:${LONGHORN_CSI_ATTACHER_VERSION:-v4.2.0}"
        "longhornio/livenessprobe:${LONGHORN_LIVENESSPROBE_VERSION:-v2.9.0}"
        "longhornio/support-bundle-kit:${LONGHORN_SUPPORT_BUNDLE_KIT_VERSION:-v0.0.25}"

        # vsphere csi/cpi
        "gcr.io/cloud-provider-vsphere/cpi/release/manager:${VSPHERE_CPI_MANAGER_VERSION:-v1.23.0}"
        "gcr.io/cloud-provider-vsphere/csi/release/driver:${VSPHERE_CSI_DRIVER_VERSION:-v2.5.1}"
        "gcr.io/cloud-provider-vsphere/csi/release/syncer:${VSPHERE_CSI_SYNCER_VERSION:-v2.5.1}"
        "registry.k8s.io/sig-storage/livenessprobe:${LIVENESSPROBE_VERSION:-v2.7.0}"
        "registry.k8s.io/sig-storage/csi-node-driver-registrar:${CSI_NODE_DRIVER_REGISTRAR_VERSION:-v2.5.1}"
        "registry.k8s.io/sig-storage/csi-attacher:${CSI_ATTACHER_VERSION:-v3.4.0}"
        "registry.k8s.io/sig-storage/csi-resizer:${CSI_RESIZER_VERSION:-v1.4.0}"
        "registry.k8s.io/sig-storage/csi-provisioner:${CSI_PROVISIONER_VERSION:-v3.1.0}"
        "registry.k8s.io/sig-storage/csi-snapshotter:${CSI_SNAPSHOTTER_VERSION:-v5.0.1}"
        "registry.k8s.io/sig-storage/snapshot-controller:${CSI_SNAPSHOT_CONTROLLER_VERSION:-v5.0.1}"
        "registry.k8s.io/sig-storage/snapshot-validation-webhook:${CSI_SNAPSHOT_VALIDATION_WEBHOOK_VERSION:-v5.0.1}"

        # confluent shit, https://docs.confluent.io/operator/current/co-custom-registry.html
        "confluentinc/confluent-init-container:${CONFLUENTINC_INIT_CONTAINER_VERSION:-2.3.1}"
        "confluentinc/confluent-operator:${CONFLUENTINC_OPERATOR_VERSION:-0.435.23}"
        "confluentinc/cp-enterprise-control-center:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-enterprise-replicator:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-kafka-rest:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-ksqldb-server:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-ksqldb-cli:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-schema-registry:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-server:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-server-connect:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "confluentinc/cp-zookeeper:${CONFLUENTINC_CP_VERSION:-7.1.1}"
        "obsidiandynamics/kafdrop:${KAFDROP_VERSION:-3.30.0}"
        "tchiotludo/akhq:${AKHQ_VERSION:-0.21.0}"

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

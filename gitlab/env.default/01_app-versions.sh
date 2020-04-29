#!/usr/bin/env bash -eux

test ! -z "${SSL_EXPORTER_VERSION:-}"
test ! -z "${TRAEFIK_VERSION:-}"
test ! -z "${ETCD_VERSION:-}"
test ! -z "${PROMETHEUS_VERSION:-}"
test ! -z "${ALERTMANAGER_VERSION:-}"
test ! -z "${NODE_EXPORTER_VERSION:-}"
test ! -z "${CONSUL_EXPORTER_VERSION:-}"
test ! -z "${BLACKBOX_EXPORTER_VERSION:-}"
test ! -z "${SNMP_EXPORTER_VERSION:-}"
test ! -z "${GRAFANA_VERSION:-}"
test ! -z "${M3DBNODE_VERSION:-}"
test ! -z "${M3COORDINATOR_VERSION:-}"
test ! -z "${PROMETHEUS_ES_EXPORTER_VERSION:-}"

# End of file
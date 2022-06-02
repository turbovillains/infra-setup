#!/bin/bash

function wait_for_process() {
  local max_time_wait=30
  local process_name="${1}"
  local waited_sec=0
  while ! pgrep "${process_name}" >/dev/null && ((waited_sec < max_time_wait)); do
    echo "Process ${process_name} is not running yet. Retrying in 1 seconds"
    echo "Waited ${waited_sec} seconds of ${max_time_wait} seconds"
    sleep 1
    ((waited_sec = waited_sec + 1))
    if ((waited_sec >= max_time_wait)); then
      return 1
    fi
  done
  return 0
}

# TODO: support DOCKERD_IN_RUNNER here to not run dockerd

echo 'Configuring Docker daemon'
mkdir -p /etc/docker

echo "{}" >/etc/docker/daemon.json

if [[ -n "${MTU}" ]]; then
  jq ".\"mtu\" = ${MTU}" /etc/docker/daemon.json >/tmp/.daemon.json && mv /tmp/.daemon.json /etc/docker/daemon.json
  # See https://docs.docker.com/engine/security/rootless/
  echo "environment=DOCKERD_ROOTLESS_ROOTLESSKIT_MTU=${MTU}" >>/etc/supervisor/conf.d/dockerd.conf
fi

if [[ -n "${DOCKER_REGISTRY_MIRROR}" ]]; then
  jq ".\"registry-mirrors\"[0] = \"${DOCKER_REGISTRY_MIRROR}\"" /etc/docker/daemon.json >/tmp/.daemon.json && mv /tmp/.daemon.json /etc/docker/daemon.json
fi

echo 'Starting supervisor daemon'
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf -n >>/dev/null 2>&1 &

echo 'Waiting for processes to be running...'
processes=(dockerd)

for process in "${processes[@]}"; do
  wait_for_process "${process}"
  if [[ $? -ne 0 ]]; then
    echo "${process} is not running after max time"
    echo 'Dumping {path} to aid investigation'
    tail -n 1000 /var/log/supervisor/*-stderr*.log /var/log/supervisor/supervisord.log
    exit 1
  else
    echo "${process} is running"
  fi
done

if [[ -n "${MTU}" ]]; then
  echo "Setting docker0 MTU to ${MTU}..."
  ip link set dev docker0 mtu ${MTU}
fi

if [[ ! -z "${DOCKER_STARTUP_PRUNE}" ]]; then
  docker system prune -af || true
  docker volume prune -f || true
fi

wait

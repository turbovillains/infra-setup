#!/bin/bash

finish () {
    wg-quick down wg0
    exit 0
}
trap finish SIGTERM SIGINT SIGQUIT

[[ -f /etc/wireguard/wg0.conf ]] && wg-quick up /etc/wireguard/wg0.conf

# Infinite sleep
# sleep infinity &
traefik &

# Health check
if [[ -n "${ENABLE_HEALTHCHECK}" ]]; then
    /usr/bin/healthcheck &
fi

wait $!

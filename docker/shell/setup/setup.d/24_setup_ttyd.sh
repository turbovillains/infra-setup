#!/usr/bin/env bash -eux

# Plane linux arch
ARCHZ=$(uname -m)

# ttyd
curl -sLo /usr/local/bin/ttyd https://github.com/tsl0922/ttyd/releases/download/$(curl -s "https://api.github.com/repos/tsl0922/ttyd/releases/latest" | jq -r '.tag_name')/ttyd.${ARCHZ}
chmod +x /usr/local/bin/ttyd

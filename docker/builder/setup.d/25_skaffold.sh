#!/usr/bin/env bash -eux

curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/v1.21.0/skaffold-linux-amd64 && chmod +x skaffold && mv skaffold /usr/local/bin
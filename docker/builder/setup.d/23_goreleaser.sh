#!/usr/bin/env bash -eux

curl -sOL https://github.com/goreleaser/goreleaser/releases/download/v0.162.0/goreleaser_amd64.deb
shasum -a 256 goreleaser_amd64.deb | grep e5963c60c883d3ed08ab06612d9f640ff34770176fba825d6e94713b7099a561
dpkg -i goreleaser_amd64.deb
rm -f goreleaser_amd64.deb
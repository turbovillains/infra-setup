#!/usr/bin/env bash -eux

export DOCKER_HUB=cr.nrtn.dev

mkdir -p /root/.docker /home/${BUILDER_USER}/.docker

cat <<END | base64 --decode | tee /root/.docker/config.json | tee /home/${BUILDER_USER}/.docker/config.json
ewogICAgImF1dGhzIjogewogICAgICAgICJjci5ucnRuLmRldiI6IHsKICAgICAgICAgICAgImF1dGgiOiAiYjJ4bGEzTnBhVG94TWpNeU16UXpORFU9IgogICAgICAgIH0sCiAgICAgICAgImh0dHBzOi8vaW5kZXguZG9ja2VyLmlvL3YxLyI6IHsKICAgICAgICAgICAgImF1dGgiOiAiYm05eWIzVjBhVzVsT2pFeVlXRXhNV1F4TFdFeVl6SXRORGhqT1MwNVlqVmlMV0k0WldVMVpUVXdOemxsTVE9PSIKICAgICAgICB9CiAgICB9Cn0K
END

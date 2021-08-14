#!/usr/bin/env bash -eux

export ALL_PROXY=${HTTP_PROXY:-http://proxy.bo01.noroutine.me:3128}
export all_proxy=${HTTP_PROXY:-http://proxy.bo01.noroutine.me:3128}
export HTTP_PROXY=${HTTP_PROXY:-http://proxy.bo01.noroutine.me:3128}
export http_proxy=${HTTP_PROXY:-http://proxy.bo01.noroutine.me:3128}
export HTTPS_PROXY=${HTTPS_PROXY:-http://proxy.bo01.noroutine.me:3128}
export https_proxy=${HTTPS_PROXY:-http://proxy.bo01.noroutine.me:3128}
export NO_PROXY=${NO_PROXY:-".noroutine.me,.nrtn.dev,10.0.0.0/8,localhost,127.0.0.1"}
export no_proxy=${NO_PROXY:-".noroutine.me,.nrtn.dev,10.0.0.0/8,localhost,127.0.0.1"}
#!/usr/bin/env bash -eux

export HTTP_PROXY=http://bo01-vm-proxy01.node.bo01.noroutine.me:3128
export HTTPS_PROXY=http://bo01-vm-proxy01.node.bo01.noroutine.me:3128
export NO_PROXY="*.noroutine.me,localhost,127.0.0.1"
# Multi-platform build notes

change platoforms param in 02_lib.sh

--platform linux/amd64,linux/arm64 \

# Single images
some are built with direct docker build

## Gradle and Android SDK

android-sdk
gradle

amd64 had extra packages lib32stdc++6 lib32z1

removed packages, will have to test

## vsphere csi driver and syncer are not building

no manifest for arm
    DOCKER_BUILDER_TARGET_PLATFORM: linux/amd64

## bitnami-mongodb

no manifest for arm
overriden     DOCKER_BUILDER_TARGET_PLATFORM: linux/amd64

## bitnami-grafana-image-renderer

no manifest for arm
overriden     DOCKER_BUILDER_TARGET_PLATFORM: linux/amd64

## ipmi exporter

does not compile for arm
overriden     DOCKER_BUILDER_TARGET_PLATFORM: linux/amd64

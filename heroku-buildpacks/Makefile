.EXPORT_ALL_VARIABLES:

SHELL=/bin/bash -o pipefail
DOCKER_HUB?=cr.nrtn.dev
BUILDPACKS_BASE?=infra/heroku-20
BUILDPACKS_BASE_VERSION?=20
BUILDPACKS_VERSION?=20

info:
	@echo Building buildpacks version ${BUILDPACKS_VERSION}

build: info
	@docker build --pull -f Dockerfile.build																										\
		--build-arg STACK=heroku-20																																\
		--build-arg BASE_IMAGE=${DOCKER_HUB}/${BUILDPACKS_BASE}-build:${BUILDPACKS_BASE_VERSION}	\
		-t ${DOCKER_HUB}/infra/pack-build:20 .

	@docker build --pull -f Dockerfile.run																											\
		--build-arg STACK=heroku-20																																\
		--build-arg BASE_IMAGE=${DOCKER_HUB}/${BUILDPACKS_BASE}:${BUILDPACKS_BASE_VERSION}				\
		-t ${DOCKER_HUB}/infra/pack:20 .

	@pack builder create ${DOCKER_HUB}/infra/buildpacks:${BUILDPACKS_VERSION} --config builder-20.toml --pull-policy if-not-present
	# @pack builder create ${DOCKER_HUB}/infra/spring-boot-buildpacks:${BUILDPACKS_VERSION} --config spring-boot-builder-20.toml --pull-policy if-not-present

publish: build
	@docker push ${DOCKER_HUB}/infra/pack-build:20
	@docker push ${DOCKER_HUB}/infra/pack:20
	@docker push ${DOCKER_HUB}/infra/buildpacks:${BUILDPACKS_VERSION}
	# @docker push ${DOCKER_HUB}/infra/spring-boot-buildpacks:${BUILDPACKS_VERSION}

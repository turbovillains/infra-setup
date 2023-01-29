.EXPORT_ALL_VARIABLES:

SHELL=/bin/bash -o pipefail
DOCKER_HUB?=cr.nrtn.dev
BUILDPACKS_BASE?=infra/heroku-20
BUILDPACKS_BASE_VERSION?=20
BUILDPACKS_VERSION?=20

info:
	@echo Building buildpacks version ${BUILDPACKS_VERSION}

build20: info
	@docker build --no-cache --pull -f Dockerfile.build																										\
		--build-arg STACK=heroku-20																																\
		--build-arg BASE_IMAGE=${DOCKER_HUB}/${BUILDPACKS_BASE}-build:${BUILDPACKS_BASE_VERSION}	\
		-t ${DOCKER_HUB}/infra/pack-build:20 .

	@docker build --no-cache --pull -f Dockerfile.run																											\
		--build-arg STACK=heroku-20																																\
		--build-arg BASE_IMAGE=${DOCKER_HUB}/${BUILDPACKS_BASE}:${BUILDPACKS_BASE_VERSION}				\
		-t ${DOCKER_HUB}/infra/pack:20 .

	@pack builder create ${DOCKER_HUB}/infra/buildpacks:${BUILDPACKS_VERSION} --config builder-20.toml --pull-policy always

publish20: build20
	@docker push ${DOCKER_HUB}/infra/pack-build:20
	@docker push ${DOCKER_HUB}/infra/pack:20
	@docker push ${DOCKER_HUB}/infra/buildpacks:${BUILDPACKS_VERSION}


build22: info
	@docker build --pull -f Dockerfile.build																										\
		--build-arg STACK=heroku-22																																\
		--build-arg BASE_IMAGE=${DOCKER_HUB}/${BUILDPACKS_BASE}-build:${BUILDPACKS_BASE_VERSION}	\
		-t ${DOCKER_HUB}/infra/pack-build:22 .

	@docker build --pull -f Dockerfile.run																											\
		--build-arg STACK=heroku-22																																\
		--build-arg BASE_IMAGE=${DOCKER_HUB}/${BUILDPACKS_BASE}:${BUILDPACKS_BASE_VERSION}				\
		-t ${DOCKER_HUB}/infra/pack:22 .

	@pack builder create ${DOCKER_HUB}/infra/buildpacks:${BUILDPACKS_VERSION} --config builder-22.toml --pull-policy if-not-present

publish22: build22
	@docker push ${DOCKER_HUB}/infra/pack-build:22
	@docker push ${DOCKER_HUB}/infra/pack:22
	# @docker push ${DOCKER_HUB}/infra/buildpacks:${BUILDPACKS_VERSION}

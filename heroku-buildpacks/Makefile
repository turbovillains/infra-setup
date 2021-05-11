.EXPORT_ALL_VARIABLES:

SHELL=/bin/bash -o pipefail
DOCKER_HUB?=bo01-vm-nexus01.node.bo01.noroutine.me:5000
BUILDPACKS_VERSION?=20

info:
	@echo Building buildpacks version ${BUILDPACKS_VERSION}

build: info
	@docker build --pull -f Dockerfile.build							\
		--build-arg STACK=heroku-20									\
		--build-arg BASE_IMAGE=${DOCKER_HUB}/heroku/heroku:20-build		\
		-t ${DOCKER_HUB}/heroku/pack:20-build .
	@docker build --pull -f Dockerfile.run								\
		--build-arg STACK=heroku-20									\
		--build-arg BASE_IMAGE=${DOCKER_HUB}/heroku/heroku:20			\
		-t ${DOCKER_HUB}/heroku/pack:20 .
	@pack builder create ${DOCKER_HUB}/heroku/buildpacks:${BUILDPACKS_VERSION} --config builder-20.toml --pull-policy if-not-present
	@pack builder create ${DOCKER_HUB}/heroku/spring-boot-buildpacks:${BUILDPACKS_VERSION} --config spring-boot-builder-20.toml --pull-policy if-not-present

publish: build
	@docker push ${DOCKER_HUB}/heroku/pack:20-build
	@docker push ${DOCKER_HUB}/heroku/pack:20
	@docker push ${DOCKER_HUB}/heroku/buildpacks:${BUILDPACKS_VERSION}
	@docker push ${DOCKER_HUB}/heroku/spring-boot-buildpacks:${BUILDPACKS_VERSION}

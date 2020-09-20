ARG DOCKER_HUB
ARG GATSBY_BUILD_BASE
ARG GATSBY_VERSION

FROM ${DOCKER_HUB}/${GATSBY_BUILD_BASE}

MAINTAINER Noroutine GmbH <info@noroutine.me>

RUN yarn global add gatsby-cli@${GATSBY_VERSION}
RUN gatsby telemetry --disable

ONBUILD WORKDIR /app
ONBUILD ADD . ./
ONBUILD RUN yarn
ONBUILD RUN gatsby build
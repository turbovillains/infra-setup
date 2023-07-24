ARG DOCKER_HUB
ARG STACK_IMAGE

FROM ${DOCKER_HUB}/${STACK_IMAGE}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

RUN groupadd heroku --gid 1000 && \
  useradd heroku -u 1000 -g 1000 -s /bin/bash -m

RUN mkdir /app && \
  chown heroku:heroku /app

ENV CNB_USER_ID=1000
ENV CNB_GROUP_ID=1000

ENV CNB_STACK_ID "heroku-22"
LABEL io.buildpacks.stack.id="heroku-22"

USER heroku

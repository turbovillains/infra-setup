ARG DOCKER_HUB
ARG STACK_IMAGE

FROM ${DOCKER_HUB}/${STACK_IMAGE}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

RUN ln -s /workspace /app

RUN groupadd heroku --gid 1000 && \
  useradd heroku -u 1000 -g 1000 -s /bin/bash -m

LABEL io.buildpacks.stack.id="heroku-22"
USER heroku
ENV HOME /app

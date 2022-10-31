ARG DOCKER_HUB
ARG INFRA_VERSION

# Dashboards
FROM ${DOCKER_HUB}/infra/debian:${INFRA_VERSION} as dashboards_build
ARG GRIT_VERSION

RUN apt-get update && apt-get install -yyq git gnupg2 curl python3 python3-pip && \
  rm -rf /var/lib/apt/lists/*

ADD dashboards /app/dashboards

WORKDIR /app

RUN python3 -V && python3 -m pip install noroutine-grit==${GRIT_VERSION}
RUN python3 -m grit generate --module dashboards --out 'out/{environment}' --var 'environment=*'

FROM scratch

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY --from=dashboards_build /app/out /dashboards

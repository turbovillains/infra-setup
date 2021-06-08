ARG DOCKER_HUB
ARG INFRA_VERSION
ARG RSHINY_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/rocker/shiny:${RSHINY_VERSION}

MAINTAINER Noroutine GmbH <info@noroutine.me>

# full bundle of CA certs set from Mozilla + Noroutine CA certs
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

COPY entrypoint.sh /entrypoint.sh
RUN chown -R shiny /usr/local/lib/R/site-library /entrypoint.sh

USER shiny

COPY base_bootstrap.R /home/shiny/base_bootstrap.R
RUN Rscript /home/shiny/base_bootstrap.R
COPY shiny-server.conf /etc/shiny-server/shiny-server.conf
ENTRYPOINT [ "/entrypoint.sh" ]

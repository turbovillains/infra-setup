ARG DOCKER_HUB
ARG INFRA_VERSION
ARG BITNAMI_KEYCLOAK_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/bitnami/keycloak:${BITNAMI_KEYCLOAK_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

# Themes
COPY scripts/ /docker-entrypoint-initdb.d
RUN chmod +x /docker-entrypoint-initdb.d/*.sh
RUN rm -rf /opt/bitnami/keycloak/themes/keycloak.v2
COPY themes/ /opt/bitnami/keycloak/themes

USER 1001

ENV KEYCLOAK_DEFAULT_THEME=noroutine-sso.v3
ENV KEYCLOAK_WELCOME_THEME=noroutine-sso.v3
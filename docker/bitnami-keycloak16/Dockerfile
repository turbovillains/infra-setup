ARG DOCKER_HUB
ARG INFRA_VERSION
ARG BITNAMI_KEYCLOAK16_VERSION
ARG KEYCLOAK_THEMES_IMAGE

FROM ${KEYCLOAK_THEMES_IMAGE} as themes

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/bitnami/keycloak:${BITNAMI_KEYCLOAK16_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

# Themes
COPY scripts/ /docker-entrypoint-initdb.d
RUN chmod +x /docker-entrypoint-initdb.d/*.sh
RUN rm -rf /opt/bitnami/keycloak/themes/keycloak.v2
COPY --from=themes --chown=1001:1001 /workspace/dist/ /opt/bitnami/keycloak/themes

USER 1001

ENV KEYCLOAK_DEFAULT_THEME=noroutine-sso
ENV KEYCLOAK_WELCOME_THEME=noroutine-sso
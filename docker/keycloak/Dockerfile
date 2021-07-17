ARG DOCKER_HUB
ARG KEYCLOAK_VERSION
ARG KEYCLOAK_THEMES_IMAGE

FROM ${KEYCLOAK_THEMES_IMAGE} as themes

FROM ${DOCKER_HUB}/keycloak/keycloak:${KEYCLOAK_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# Themes

RUN rm -rf /opt/jboss/keycloak/themes/keycloak.v2
COPY --from=themes --chown=0:0 /workspace/dist/ /opt/jboss/keycloak/themes

ENV KEYCLOAK_DEFAULT_THEME=noroutine-sso
ENV KEYCLOAK_WELCOME_THEME=noroutine-sso
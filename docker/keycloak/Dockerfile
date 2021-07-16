ARG DOCKER_HUB
ARG KEYCLOAK_VERSION
FROM ${DOCKER_HUB}/keycloak/keycloak:${KEYCLOAK_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# Themes

RUN rm -rf /opt/jboss/keycloak/themes/keycloak.v2
COPY themes/ /opt/jboss/keycloak/themes

ENV KEYCLOAK_DEFAULT_THEME=noroutine-sso
ENV KEYCLOAK_WELCOME_THEME=noroutine-sso
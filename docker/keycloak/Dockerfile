ARG DOCKER_HUB
ARG KEYCLOAK_VERSION
ARG KEYCLOAK_THEMES_IMAGE

FROM ${KEYCLOAK_THEMES_IMAGE} as themes

FROM ${DOCKER_HUB}/keycloak/keycloak:${KEYCLOAK_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# Themes

COPY --from=themes --chown=0:0 /workspace/dist/ /opt/keycloak/themes

ENV KC_SPI_THEME_DEFAULT=noroutine-sso

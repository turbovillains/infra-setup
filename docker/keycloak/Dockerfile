ARG DOCKER_HUB
ARG KEYCLOAK_VERSION
ARG KEYCLOAK_THEMES_IMAGE

FROM ${KEYCLOAK_THEMES_IMAGE} as themes

FROM ${DOCKER_HUB}/keycloak/keycloak:${KEYCLOAK_VERSION}

ARG EMAIL_TOTP_AUTH_VERSION

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# Themes
ENV EMAIL_TOTP_AUTH_VERSION=${EMAIL_TOTP_AUTH_VERSION}
ADD --chown=1000 \
  "https://github.com/5-stones/keycloak-email-otp/releases/download/v${EMAIL_TOTP_AUTH_VERSION}/com.weare5stones.keycloak.authenticators-emailtotp-${EMAIL_TOTP_AUTH_VERSION}.jar" \
  /opt/keycloak/providers/

COPY --from=themes --chown=1000 /workspace/dist/ /opt/keycloak/themes

# ENV KC_SPI_THEME_DEFAULT=noroutine-sso

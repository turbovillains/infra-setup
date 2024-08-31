ARG DOCKER_HUB=cr.nrtn.dev
ARG INFRA_VERSION
ARG INFRA_NAMESPACE=infra
ARG BITNAMI_KEYCLOAK_VERSION
ARG KEYCLOAK_THEMES_IMAGE

FROM ${KEYCLOAK_THEMES_IMAGE} AS themes

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} AS rootca

FROM ${DOCKER_HUB}/bitnami/keycloak:${BITNAMI_KEYCLOAK_VERSION}

ARG EMAIL_TOTP_AUTH_VERSION

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

ENV EMAIL_TOTP_AUTH_VERSION=${EMAIL_TOTP_AUTH_VERSION}
ADD --chown=1001 \
  "https://github.com/5-stones/keycloak-email-otp/releases/download/v${EMAIL_TOTP_AUTH_VERSION}/com.weare5stones.keycloak.authenticators-emailtotp-${EMAIL_TOTP_AUTH_VERSION}.jar" \
  /opt/bitnami/keycloak/providers/

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

# Themes
COPY --from=themes --chown=1001:1001 /workspace/dist/ /opt/bitnami/keycloak/themes

USER 1001

# ENV KC_SPI_THEME_DEFAULT=noroutine-sso

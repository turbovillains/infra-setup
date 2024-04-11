ARG DOCKER_HUB
ARG INFRA_VERSION
ARG INFRA_NAMESPACE
ARG ARGO_EVENTS_VERSION

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/argoproj/argo-events:${ARGO_EVENTS_VERSION} as argo-events

FROM ${DOCKER_HUB}/${INFRA_NAMESPACE}/debian:${INFRA_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY --from=argo-events /usr/local/bin/argo /usr/local/bin/argo
COPY --from=argo-events /bin/argo-events /bin/argo-events

ENTRYPOINT [ "/bin/argo-events" ]

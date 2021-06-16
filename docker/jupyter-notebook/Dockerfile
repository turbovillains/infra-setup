ARG DOCKER_HUB
ARG INFRA_VERSION
ARG JUPYTER_VERSION
ARG FLAVOUR

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

FROM ${DOCKER_HUB}/jupyter/${FLAVOUR}-notebook:${JUPYTER_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

# full bundle of CA certs set from Mozilla + Noroutine CA certs
USER 0
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

USER $NB_UID

RUN pip install nbgitpuller
RUN jupyter serverextension enable --sys-prefix nbgitpuller
RUN pip install --upgrade jupyterlab jupyterlab-git
ARG DOCKER_HUB
ARG INFRA_VERSION
ARG JUPYTER_VERSION

FROM ${DOCKER_HUB}/infra/noroutine-ca:${INFRA_VERSION} as rootca

# This should be our notebook image
FROM ${DOCKER_HUB}/jupyter/all-spark-notebook:${JUPYTER_VERSION}

ARG RSTUDIO_VERSION

USER 0

# full bundle of CA certs set from Mozilla + Noroutine CA certs
COPY --from=rootca /noroutine /usr/local/share/ca-certificates/noroutine
RUN update-ca-certificates

# This should be probably part of notebook
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        postgresql-client \
        libgirepository1.0-dev \
        libcairo2-dev \
        python3-dev \
        gir1.2-secret-1 \
        libaio1 \
        libapparmor1 \
        libclang-dev \
        libedit2 \
        lsb-release \
        psmisc \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

RUN curl -sL -o rstudio-server.deb https://download2.rstudio.org/server/bionic/amd64/rstudio-server-${RSTUDIO_VERSION}-amd64.deb && \
    dpkg -i rstudio-server.deb && \
    rm rstudio-server.deb

USER $NB_UID

RUN pip install git+https://github.com/jupyterhub/jupyter-rsession-proxy

RUN jupyter serverextension enable --sys-prefix jupyter_server_proxy && \
    jupyter labextension install @jupyterlab/server-proxy

ENV PATH="${PATH}:/usr/lib/rstudio-server/bin"
ENV LD_LIBRARY_PATH="/usr/lib/R/lib:/lib:/usr/lib/x86_64-linux-gnu:/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/amd64/server:/opt/conda/lib/R/lib"

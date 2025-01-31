ARG IMAGE_REGISTRY
ARG IMAGE_BASE
ARG IMAGE_VERSION

FROM ${IMAGE_REGISTRY}/${IMAGE_BASE}:${IMAGE_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

# See compatibility before changing version https://github.com/peteeckel/netbox-plugin-dns
RUN . /opt/netbox/venv/bin/activate && \
    /usr/local/bin/uv pip install netbox-plugin-dns

# Patch nginx-unit.json with dualstack one that has no whitelisting 
COPY nginx-unit.json /etc/unit/nginx-unit.json

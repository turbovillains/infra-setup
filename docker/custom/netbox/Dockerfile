ARG IMAGE_REGISTRY=cr.nrtn.dev
ARG INFRA_NAMESPACE=infra-dev
ARG INFRA_VERSION=dev
ARG IMAGE_BASE=dev
ARG IMAGE_VERSION=dev

FROM ${IMAGE_REGISTRY}/${IMAGE_BASE}:${IMAGE_VERSION}

# See compatibility before changing version https://github.com/peteeckel/netbox-plugin-dns
RUN . /opt/netbox/venv/bin/activate && \
    /usr/local/bin/uv pip install netbox-plugin-dns

# Patch nginx-unit.json with dualstack one that has no whitelisting 
COPY nginx-unit.json /etc/unit/nginx-unit.json

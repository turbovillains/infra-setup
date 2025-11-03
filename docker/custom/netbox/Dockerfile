ARG IMAGE_REGISTRY=cr.nrtn.dev
ARG NETBOX_VERSION=dev

FROM ${IMAGE_REGISTRY}/netboxcommunity/netbox:${NETBOX_VERSION}

# See compatibility before changing version https://github.com/peteeckel/netbox-plugin-dns
RUN . /opt/netbox/venv/bin/activate && \
    /usr/local/bin/uv pip install netbox-plugin-dns

# Patch nginx-unit.json with dualstack one that has no whitelisting 
COPY nginx-unit.json /etc/unit/nginx-unit.json

ARG IMAGE_REGISTRY=cr.nrtn.dev
ARG PYTHON_VERSION=dev

FROM ${IMAGE_REGISTRY}/library/python:${PYTHON_VERSION}

# Install uv system-wide
RUN curl -LsSf https://astral.sh/uv/install.sh | \
    env UV_INSTALL_DIR=/usr/local/bin sh

ARG DOCKER_HUB
ARG ELASTICSEARCH_VERSION
FROM ${DOCKER_HUB}/elastic/elasticsearch/elasticsearch:${ELASTICSEARCH_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

RUN /usr/share/elasticsearch/bin/elasticsearch-plugin install --batch ingest-attachment

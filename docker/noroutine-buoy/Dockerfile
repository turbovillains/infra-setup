ARG DOCKER_HUB=cr.nrtn.dev
ARG INFRA_VERSION=v0.0.384
ARG INFRA_NAMESPACE=infra
ARG ALPINE_VERSION=3.21.3

FROM ${DOCKER_HUB}/library/alpine:${ALPINE_VERSION} AS alpine

RUN apk update && apk add --no-cache ca-certificates nginx openssl && \
  mkdir -p /usr/share/nginx/html

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

COPY nginx.conf /etc/nginx/nginx.conf
COPY certs/ /etc/nginx/certs/
COPY generate_response.sh /
COPY banner.txt /etc/banner.txt

EXPOSE 443

# Environment variable for custom instructions
ENV BUOY_INSTRUCTIONS="Default buoy instructions"

# Generate the response file and start nginx
CMD ["/bin/sh", "-c", "/generate_response.sh && nginx -g 'daemon off;'"]
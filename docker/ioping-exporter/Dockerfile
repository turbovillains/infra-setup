ARG DOCKER_HUB
ARG GOLANG_VERSION
ARG ALPINE_VERSION

FROM ${DOCKER_HUB}/golang:${GOLANG_VERSION}
RUN echo ${DOCKER_HUB}
RUN apk --no-cache add git
RUN go get github.com/fihuer/ioping_exporter

FROM ${DOCKER_HUB}/alpine:${ALPINE_VERSION}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

COPY --from=0 /go/bin/ioping_exporter /ioping-exporter
RUN apk --no-cache add ioping
EXPOSE 9101
ENTRYPOINT [ "/ioping-exporter" ]
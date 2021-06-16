ARG DOCKER_HUB

FROM ${DOCKER_HUB}/golang:1.14-alpine
RUN echo ${DOCKER_HUB}
RUN apk --no-cache add git
RUN go get github.com/fihuer/ioping_exporter

FROM ${DOCKER_HUB}/alpine:3.11

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

COPY --from=0 /go/bin/ioping_exporter /ioping-exporter
RUN apk --no-cache add ioping
EXPOSE 9101
ENTRYPOINT [ "/ioping-exporter" ]
ARG ALPINE_IMAGE=alpine:3.15.0
ARG GOLANG_ALPINE_IMAGE=golang:1.17.3-alpine3.14

FROM ${GOLANG_ALPINE_IMAGE} AS build_base
ARG SPEEDTEST_VERSION=v1.1.4

# ENV GOARCH arm64
ENV GOARCH amd64
RUN apk add --no-cache git gcc ca-certificates libc-dev && \
  mkdir -p /go/src/github.com/librespeed/ && \
  cd /go/src/github.com/librespeed/ && \
  git clone https://github.com/librespeed/speedtest-go.git && \
  cd speedtest-go && \
  git checkout ${SPEEDTEST_VERSION}

WORKDIR /go/src/github.com/librespeed/speedtest-go
RUN go get ./ && go build -ldflags "-w -s" -trimpath -o speedtest main.go

FROM ${ALPINE_IMAGE}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

RUN apk add ca-certificates
WORKDIR /app
COPY --from=build_base /go/src/github.com/librespeed/speedtest-go/speedtest .
COPY --from=build_base /go/src/github.com/librespeed/speedtest-go/web/assets ./assets
COPY --from=build_base /go/src/github.com/librespeed/speedtest-go/settings.toml .

EXPOSE 8989

CMD ["./speedtest"]
FROM golang:1.15.3-alpine3.12 AS build_base
ARG SPEEDTEST_VERSION
# ENV GOARCH arm64
ENV GOARCH amd64
RUN apk add --no-cache git gcc ca-certificates libc-dev \
&& mkdir -p /go/src/github.com/librespeed/ \
&& cd /go/src/github.com/librespeed/ \
&& git clone https://github.com/librespeed/speedtest-go.git \
&& cd speedtest-go \
&& git checkout ${SPEEDTEST_VERSION}
WORKDIR /go/src/github.com/librespeed/speedtest-go
RUN go get ./ && go build -ldflags "-w -s" -trimpath -o speedtest main.go

FROM alpine:3.12.1

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

RUN apk add ca-certificates
WORKDIR /app
COPY --from=build_base /go/src/github.com/librespeed/speedtest-go/speedtest .
COPY --from=build_base /go/src/github.com/librespeed/speedtest-go/assets ./assets
COPY --from=build_base /go/src/github.com/librespeed/speedtest-go/settings.toml .

EXPOSE 8989

CMD ["./speedtest"]
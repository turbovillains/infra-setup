FROM golang:1.7.3

WORKDIR /app

COPY main.go .
RUN go get -d -v golang.org/x/net/html \
  && CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o dex-secret-generator .

## Exec docker
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=0 /app/dex-secret-generator .
ENTRYPOINT ["./dex-secret-generator"]

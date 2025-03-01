# Buoy Server for private Noroutine Network

```
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout certs/buoy-key.pem -out certs/buoy-cert.pem -subj "/CN=buoy-server" -addext "subjectAltName = DNS:buoy-server,DNS:*.buoy-server,IP:0.0.0.0"

```
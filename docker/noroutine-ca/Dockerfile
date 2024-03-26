FROM scratch

ADD noroutine noroutine

# full bundle of CA certs set from Mozilla + Noroutine CA certs
ADD https://nexus.nrtn.dev/repository/noroutine-ca/cacerts.pem ca-certificates.crt

# Add artifacts from nexus
ADD https://nexus.nrtn.dev/repository/noroutine-ca/cacerts.pem cacerts.pem
ADD https://nexus.nrtn.dev/repository/noroutine-ca/cacerts.p12 cacerts.p12
ADD https://nexus.nrtn.dev/repository/noroutine-ca/cacerts.jks cacerts.jks
ADD https://nexus.nrtn.dev/repository/noroutine-ca/noroutine-root-ca.crt.pem noroutine-root-ca.crt.pem
ADD https://nexus.nrtn.dev/repository/noroutine-ca/noroutine-trusted-ca.crt.pem noroutine-trusted-ca.crt.pem

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.com>"

FROM scratch

ADD noroutine noroutine

# full bundle of CA certs set from Mozilla + Noroutine CA certs
ADD https://infra.noroutine.me/ca/cacerts.pem ca-certificates.crt

# Add artifacts from nexus
ADD https://infra.noroutine.me/ca/cacerts.pem cacerts.pem
ADD https://infra.noroutine.me/ca/cacerts.p12 cacerts.p12
ADD https://infra.noroutine.me/ca/cacerts.jks cacerts.jks
ADD https://infra.noroutine.me/ca/noroutine-root-ca.crt.pem noroutine-root-ca.crt.pem
ADD https://infra.noroutine.me/ca/noroutine-trusted-ca.crt.pem noroutine-trusted-ca.crt.pem

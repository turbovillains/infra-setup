ssl.md
===

# Guide

https://wiki.mozilla.org/Security/Server_Side_TLS

# Generator

https://ssl-config.mozilla.org/

# Convert JKS to P12

```
keytool -importkeystore \
    -srckeystore store.jks \
    -srcstorepass 123234345 \
    -srckeypass 123234345 \
    -srcalias alias \
    -destalias alias \
    -destkeystore store.p12 \
    -deststoretype PKCS12 \
    -deststorepass 123234345 \
    -destkeypass 123234345
```

# Extract private key

```
penssl pkcs12 -in identity.p12 -nodes -nocerts
```
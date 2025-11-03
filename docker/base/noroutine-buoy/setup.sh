#!/bin/sh
# Generate a self-signed certificate valid for 10 years (3650 days)
# Using a wildcard certificate that will work regardless of IP
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout certs/buoy-key.pem -out certs/buoy-cert.pem -subj "/CN=buoy-server" -addext "subjectAltName = DNS:buoy-server,DNS:*.buoy-server,IP:0.0.0.0"

# Calculate the certificate fingerprint (with colons for display)
CERT_FINGERPRINT=$(openssl x509 -in certs/buoy-cert.pem -fingerprint -sha256 -noout | cut -d'=' -f2)
echo "Certificate fingerprint (with colons): $CERT_FINGERPRINT"

# Also calculate without colons for the response
CERTIFICATE_FINGERPRINT________________________________________=$(echo $CERT_FINGERPRINT | tr -d ':')
echo "Certificate fingerprint (without colons): $CERTIFICATE_FINGERPRINT________________________________________"

# Create a nice startup banner
cat > banner.txt <<EOF
╔════════════════════════════════════════════════════════════════════╗
║                                                                    ║
║                     PRIVATE NETWORK BUOY SERVER                    ║
║                                                                    ║
╠════════════════════════════════════════════════════════════════════╣
║                                                                    ║
║  Serving HTTPS on port 443 with self-signed certificate            ║
║  Certificate valid for 10 years                                    ║
║                                                                    ║
║  Certificate Fingerprint (SHA-256):                                ║
║  $CERTIFICATE_FINGERPRINT________________________________________  ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝
EOF

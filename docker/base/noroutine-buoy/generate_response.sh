#!/bin/sh
FINGERPRINT=$(openssl x509 -in /etc/nginx/certs/buoy-cert.pem -fingerprint -sha256 -noout | cut -d'=' -f2)
FINGERPRINT_NO_COLONS=$(echo $FINGERPRINT | tr -d ':')
INSTRUCTIONS=${BUOY_INSTRUCTIONS:-"Default buoy instructions. Set BUOY_INSTRUCTIONS env var to customize."}

cat > /usr/share/nginx/html/index.html <<EOT
Buoy server operational
Certificate fingerprint: $FINGERPRINT_NO_COLONS
Instructions: $INSTRUCTIONS
EOT

# Print the banner to stdout during container startup
cat /etc/banner.txt

echo ""
echo "$INSTRUCTIONS"
echo ""
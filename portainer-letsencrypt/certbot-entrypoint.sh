#!/bin/sh
set -e

DOMAIN="${DOMAIN:?DOMAIN environment variable is required}"
EMAIL="${EMAIL:?EMAIL environment variable is required}"

# Install docker CLI for post-renewal container restart
apk add --no-cache docker-cli > /dev/null 2>&1

# Obtain certificate if it doesn't exist
if [ ! -f "/etc/letsencrypt/live/${DOMAIN}/fullchain.pem" ]; then
    echo "Obtaining certificate for ${DOMAIN}..."
    certbot certonly \
        --dns-route53 \
        --non-interactive \
        --agree-tos \
        --email "${EMAIL}" \
        -d "${DOMAIN}" \
        --key-type ecdsa
fi

echo "Certificate ready. Starting renewal loop..."

# Check for renewal every 12 hours
while true; do
    sleep 12h
    echo "Checking certificate renewal..."
    certbot renew --deploy-hook "docker restart portainer"
done

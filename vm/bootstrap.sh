#!/bin/bash
set -eux -o pipefail # Strict mode

# Script args
DNS_ZONE_NAME=$1
DNS_DOMAIN_NAME=$2

# Script constants
FORGE_DATA=/var/forge-data
FORGE_GROUP=forge

# GCP metadata
EXTERNAL_IP=$(curl -sS -H 'Metadata-Flavor:Google' 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip')

log() {
  printf "%s\n" "$*"
}

install_os_packages() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends caddy
}

update_dns() {
  for name in "$DNS_DOMAIN_NAME." "cp.$DNS_DOMAIN_NAME."; do
    gcloud dns record-sets update "$name" --zone "$DNS_ZONE_NAME" --type A --rrdatas="$EXTERNAL_IP"
  done
}

setup_caddy() {
  echo "DOMAIN=$DNS_DOMAIN_NAME" > /etc/caddy/.env
  ln -sf "$PWD/Caddyfile" /etc/caddy/Caddyfile
  mkdir -p /etc/systemd/system/caddy.service.d
  cp -f caddy_override.conf /etc/systemd/system/caddy.service.d/override.conf

  systemctl enable caddy.service
  systemctl restart caddy.service
}

setup_forge_data() {
  groupadd -f -g 1337 "$FORGE_GROUP"
  mkdir -p "$FORGE_DATA"
  chown root:"$FORGE_GROUP" "$FORGE_DATA"
  chmod g+rwx "$FORGE_DATA"
}

main() {
  install_os_packages
  update_dns
  setup_caddy
  setup_forge_data
}

cd "$(dirname "$0")"
main

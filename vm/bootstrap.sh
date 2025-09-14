#!/bin/bash
set -eux -o pipefail # Strict mode

# Script args
DNS_ZONE_NAME=$1
DNS_DOMAIN_NAME=$2
FOUNDRY_SLOC=$3

# Script constants
FORGE_DATA_DIR=/var/forge_data
FORGE_DATA_GROUP=forge-data

# GCP metadata
EXTERNAL_IP=$(curl -sS -H 'Metadata-Flavor:Google' 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip')

log() {
  printf "%s\n" "$*"
}

install_os_packages() {
  if ! command -v node >/dev/null 2>&1; then
    curl -sS -L https://deb.nodesource.com/setup_22.x | bash -
  fi

  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    caddy nodejs python3 unzip zip
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
  groupadd -f -g 1337 "$FORGE_DATA_GROUP"
  mkdir -p "$FORGE_DATA_DIR"
  chown root:"$FORGE_DATA_GROUP" "$FORGE_DATA_DIR"
  chmod g+rwx "$FORGE_DATA_DIR"

  mkdir -p "$FORGE_DATA_DIR/Config"
  chown root:"$FORGE_DATA_GROUP" "$FORGE_DATA_DIR/Config"
  chmod g+rwx "$FORGE_DATA_DIR/Config"
}

setup_copyparty() {
  curl -sS -L 'https://github.com/9001/copyparty/releases/latest/download/copyparty-sfx.py' -o /usr/local/bin/copyparty-sfx.py

  if ! grep "^copyparty:" /etc/passwd; then
    useradd -r -s /sbin/nologin -m -d /var/lib/copyparty -G "$FORGE_DATA_GROUP" copyparty
  fi

  ln -sf "$PWD/copyparty.conf" /etc/copyparty.conf
  cp -f copyparty.service /etc/systemd/system/copyparty.service

  systemctl enable copyparty
  systemctl restart copyparty
}

setup_forge() {
  if ! grep "^forge:" /etc/passwd; then
    useradd -r -s /sbin/nologin -m -d /var/lib/forge -G "$FORGE_DATA_GROUP" forge
  fi

  if ! [[ -f '/usr/local/lib/foundry/foundryvtt' ]]; then
    gcloud storage cp "$FOUNDRY_SLOC" /tmp/foundry.zip
    unzip -qo /tmp/foundry.zip -d /usr/local/lib/foundry
  fi

  if ! [[ -f "$FORGE_DATA_DIR/Config/options.json" ]]; then
    echo '{"localHostname":"localhost","port":30000,"upnp":false}' >"$FORGE_DATA_DIR/Config/options.json"
    chown forge:"$FORGE_DATA_GROUP" "$FORGE_DATA_DIR/Config/options.json"
  fi

  cp -f forge.service /etc/systemd/system/forge.service
  systemctl enable forge
  systemctl restart forge
}

main() {
  install_os_packages
  update_dns
  setup_caddy
  setup_forge_data
  setup_copyparty
  setup_forge
}

cd "$(dirname "$0")"
main

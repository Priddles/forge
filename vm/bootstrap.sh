#!/bin/bash
set -eux -o pipefail # Strict mode

DNS_ZONE_NAME=forge

EXTERNAL_IP=$(curl -H 'Metadata-Flavor:Google' 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip')

cd "$(dirname "$0")"

log() {
  printf "%s\n" "$*"
}

install_os_packages() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends caddy
}

update_dns() {
  local args=(--zone "$DNS_ZONE_NAME")

  local records
  records=$(gcloud dns record-sets list "${args[@]}" --format 'value(name)' --filter 'type=A')

  for record in $records; do
    IFS=$'\t' read -r -a data <<<"$record"
    local name="${data[0]}"

    gcloud dns record-sets update "$name" "${args[@]}" --type A --rrdatas="$EXTERNAL_IP"
  done
}

setup_caddy() {
  ln -sf "$PWD/Caddyfile" /etc/caddy/Caddyfile
  systemctl enable caddy.service
  systemctl restart caddy.service
}

main() {
  install_os_packages
  update_dns
  setup_caddy
}

main "$@"

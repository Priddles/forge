#!/bin/bash
set -eux -o pipefail # Strict mode

cd "$(dirname "$0")"

log() {
  printf "%s\n" "$*"
}

install_os_packages() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends caddy
}

setup_caddy() {
  ln -sf "$PWD/Caddyfile" /etc/caddy/Caddyfile
  systemctl enable caddy.service
  systemctl restart caddy.service
}

main() {
  install_os_packages
  setup_caddy
}

main "$@"

#!/bin/bash
set -eux -o pipefail # Strict mode

log() {
  printf "%s\n" "$*"
}

install_os_packages() {
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends caddy
}

setup_caddy() {
  true
}

main() {
  install_os_packages
}

main "$@"

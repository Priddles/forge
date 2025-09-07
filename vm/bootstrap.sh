#!/bin/bash
set -eux -o pipefail # Strict mode

install_os_packages() {
  sudo apt-get update
  sudo apt-get upgrade -y
  sudo apt-get install caddy
}

setup_caddy() {
  true
}

main() {
  setup_caddy
}

main "$@"

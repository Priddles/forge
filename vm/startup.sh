#!/bin/bash
set -eux -o pipefail # Strict mode
trap 'shutdown now' ERR

SCRIPTS_DIR=/opt/forge

apt-get update

if ! command -v git >/dev/null 2>&1; then
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git
fi

if ! [[ -d "$SCRIPTS_DIR" ]]; then
  git clone --depth 1 "https://github.com/Priddles/forge.git" "$SCRIPTS_DIR"
fi

cd "$SCRIPTS_DIR"
git pull
bash './vm/bootstrap.sh'

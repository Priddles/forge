#!/bin/bash
set -eux -o pipefail

install() {
  sudo apt-get update

  sudo apt-get install -y nginx
  sudo systemctl stop nginx

  sudo apt-get install -y snapd
  sudo snap install --classic certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot

  # TODO: Override default nginx site.

  sudo certbot run --noninteractive --agree-tos \
    --nginx --domain forge.priddles.xyz
}

# TODO: Only run install once.
install

# TODO: Write nginx sites to: /etc/nginx/sites-available
# TODO: Create symlinks in: /etc/nginx/sites-enabled

# TODO: Update A record in DNS.

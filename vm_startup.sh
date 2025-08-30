#!/bin/bash
set -eux -o pipefail

# install configures OS packages and configures certbot and nginx
install() {
  sudo apt-get update

  sudo apt-get install -y nginx
  sudo systemctl stop nginx

  sudo apt-get install -y snapd
  sudo snap install --classic certbot
  sudo ln -s /snap/bin/certbot /usr/bin/certbot

  # TODO: Override default nginx site.
  # TODO: Create and symlink forge site.

  # TODO: Get certbot to update forge site.
  sudo certbot run --noninteractive --agree-tos \
    --nginx --domain forge.priddles.xyz

  sudo systemctl start nginx
}

# prep_data formats the data disk for use.
prep_data() {
  -E lazy_itable_init=0,lazy_journal_init=0,discard
}

# TODO: Only run install once.
install

# TODO: Update A record in DNS.

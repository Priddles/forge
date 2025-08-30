#!/bin/bash
set -eux -o pipefail

sudo apt-get update
sudo apt-get install -y nginx snapd

sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot

# TODO: Update A record in DNS.

sudo certbot run --noninteractive --agree-tos \
  --nginx \
  --domain forge.priddles.xyz

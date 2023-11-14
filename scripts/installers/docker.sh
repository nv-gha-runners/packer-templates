#!/bin/bash
set -euo pipefail

KEYRING="/usr/share/keyrings/docker.gpg"
APT="/etc/apt/sources.list.d/docker.list"

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o "${KEYRING}"
sudo chmod a+r "${KEYRING}"

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=${KEYRING}] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee "${APT}" > /dev/null
sudo apt-get update

sudo apt-get install --no-install-recommends \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin

# Install latest docker-compose from GitHub releases
COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(arch)"
CHECKSUM_URL="${COMPOSE_URL}.sha256"
wget -q "${COMPOSE_URL}" "${CHECKSUM_URL}"
sha256sum -c docker-compose-*.sha256
rm -rf docker-compose*.sha256
sudo mkdir -p /usr/libexec/docker/cli-plugins/docker-compose
chmod +x docker-compose*
sudo mv docker-compose* /usr/libexec/docker/cli-plugins/docker-compose

# Enable docker.service
systemctl is-active --quiet docker.service || systemctl start docker.service
systemctl is-enabled --quiet docker.service || systemctl enable docker.service

# Docker daemon takes time to come up after installing
sleep 10
docker info

# TODO: configure docker mirror

sudo rm -rf "${APT}" "${KEYRING}"

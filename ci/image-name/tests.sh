#!/bin/bash

set -euo pipefail

MATRIX="$(yq -o json matrix.yaml)"
LATEST_DRIVER_VERSION="$(echo "${MATRIX}" | jq -r '.DRIVER_VERSION[-1]')"

ci/image-name/deserialize.sh "linux-gpu-${LATEST_DRIVER_VERSION}-open-arm64-main" | \
  LATEST_DRIVER_VERSION="${LATEST_DRIVER_VERSION}" \
  jq -e ". == {
    \"os\": \"linux\",
    \"variant\": \"gpu\",
    \"driver_version\": env.LATEST_DRIVER_VERSION,
    \"driver_flavor\": \"open\",
    \"arch\": \"arm64\",
    \"branch_name\": \"main\"
  }"
ci/image-name/deserialize.sh "windows-cpu-amd64-pr-1234" | \
  jq -e ". == {
    \"os\": \"windows\",
    \"variant\": \"cpu\",
    \"driver_version\": null,
    \"driver_flavor\": null,
    \"arch\": \"amd64\",
    \"branch_name\": \"pr-1234\"
  }"
ci/image-name/deserialize.sh "linux-gpu-${LATEST_DRIVER_VERSION}-open-arm64" | \
  LATEST_DRIVER_VERSION="${LATEST_DRIVER_VERSION}" \
  jq -e ". == {
    \"os\": \"linux\",
    \"variant\": \"gpu\",
    \"driver_version\": env.LATEST_DRIVER_VERSION,
    \"driver_flavor\": \"open\",
    \"arch\": \"arm64\",
    \"branch_name\": null
  }"

if ci/image-name/deserialize.sh "linux-${LATEST_DRIVER_VERSION}-arm64-main"; then
  exit 1
fi
if ci/image-name/deserialize.sh "gpu-${LATEST_DRIVER_VERSION}-arm64-main"; then
  exit 1
fi
if ci/image-name/deserialize.sh "linux-gpu-${LATEST_DRIVER_VERSION}-main"; then
  exit 1
fi

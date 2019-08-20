#!/usr/bin/env bash

-set -xeuo pipefail

echo "* Hello from fly.sh"

# DL fli-cli
wget -o /tmp/fly "http://10.36.68.29:8080/api/v1/cli?arch=amd64&platform=linux"

# CHMOD +x
chmod +x /tmp/fly

# LOGIN
/tmp/fly login -t http://10.36.68.29:8080/ -u "${USERNAME}" -p "${PASWORD}"

# RE FLY       
/tmp/fly -t local sp -p display-version -c ci/pipelines/version-pipeline.yml --var version="${NEW_VERSION}" --non-interactive

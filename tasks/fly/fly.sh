#!/bin/bash

set -x

echo "* Hello from fly.sh"

env

# DL fli-cli
wget -o /tmp/fly "http://127.0.0.1:8080/api/v1/cli?arch=i386&platform=linux"

# CHMOD +x
chmod +x /tmp/fly

# LOGIN
/tmp/fly login -t http://10.36.68.29:8080/ -u "${USERNAME}" -p "${PASSWORD}"

# RE FLY       
/tmp/fly -t local sp -p display-version -c ci/pipelines/version-pipeline.yml --var version="${NEW_VERSION}" --non-interactive

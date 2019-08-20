#!/bin/bash

set -x

echo "* Hello from fly.sh"

# DL fli-cli
wget -o /tmp/fly "http://10.36.68.29:8080/api/v1/cli?arch=amd64&platform=linux"

# CHMOD +x
chmod +x /tmp/fly

ls -l /tmp/fly
whoami

# debug
type /tmp/fly
/tmp/fly -v

# LOGIN
/tmp/fly login -t http://10.36.68.29:8080/ -u "${USERNAME}" -p "${PASSWORD}"

# RE FLY       
/tmp/fly -t local sp -p display-version -c ci/pipelines/version-pipeline.yml --var version="${NEW_VERSION}" --non-interactive

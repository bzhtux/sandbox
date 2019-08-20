#!/bin/bash

set -x

echo "* Hello from fly.sh"


# DL fli-cli
wget -o /tmp/fly "https://github.com/concourse/concourse/releases/download/v5.4.1/fly-5.4.1-linux-amd64.tgz"

cd /tmp

tar xvf fly-5.4.1-linux-amd64.tgz

ls -ltr

# CHMOD +x
chmod +x /tmp/fly

# LOGIN
/tmp/fly login -t http://10.36.68.29:8080/ -u "${USERNAME}" -p "${PASSWORD}"

# RE FLY       
/tmp/fly -t local sp -p display-version -c ci/pipelines/version-pipeline.yml --var version="${NEW_VERSION}" --non-interactive

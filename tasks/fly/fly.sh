#!/bin/bash

set -x

echo "* Hello from fly.sh"


# DL fli-cli
wget -o /tmp/fly.tgz "https://github.com/concourse/concourse/releases/download/v5.4.1/fly-5.4.1-linux-amd64.tgz"

cd /tmp

cat /tmp/fly.tgz

tar xzvf fly.tgz

ls -ltr

# CHMOD +x
chmod +x /tmp/fly

# LOGIN
/tmp/fly login -t http://web:8080/ -u "${USERNAME}" -p "${PASSWORD}"

# RE FLY       
/tmp/fly -t local sp -p display-version -c ci/pipelines/version-pipeline.yml --var version="${NEW_VERSION}" --non-interactive

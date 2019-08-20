#!/bin/bash

set -x

echo "* Hello from fly.sh"


# DL fli-cli
wget -O /tmp/fly.tgz -q "https://github.com/concourse/concourse/releases/download/v5.4.1/fly-5.4.1-linux-amd64.tgz"

pushd /tmp

tar -xzf fly.tgz
cp fly /usr/local/bin/

popd

ls -l

# CHMOD +x
chmod +x /tmp/fly

# LOGIN
/tmp/fly -t local login --concourse-url http://172.20.0.3:8080/ -u "${USERNAME}" -p "${PASSWORD}"

# RE FLY       
/tmp/fly -t local sp -p display-version -c ci/pipelines/version-pipeline.yml --var version="${NEW_VERSION}" --non-interactive

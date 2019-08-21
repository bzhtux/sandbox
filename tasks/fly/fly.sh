#!/bin/bash

set -euo pipefail


# DL fli-cli
wget -O /tmp/fly.tgz -q "https://github.com/concourse/concourse/releases/download/v5.4.1/fly-5.4.1-linux-amd64.tgz"

# cd /tmp
tar -xzf /tmp/fly.tgz -C /tmp
# cp fly /usr/local/bin/

# cd $OLDPWD

/bin/ls -ltr new_version/
cat new_version/version

# CHMOD +x
chmod +x /tmp/fly

# LOGIN
/tmp/fly -t local login --concourse-url http://172.20.0.3:8080/ -u "${USERNAME}" -p "${PASSWORD}"

NEW_VERSION=$(cat new_version/version)

# RE FLY       
/tmp/fly -t local sp -p display-version -c ci/pipelines/version-pipeline.yml --var version="${NEW_VERSION}" --non-interactive
/tmp/fly -t local trigger-job -j display-version/display-version


#!/usr/bin/env bash

WORKDIR=$PWD
TMP_DIR=$(mktemp -d /tmp/bosh.XXXXXX)

set -x

tearDown(){
    if [ -d "${TMP_DIR}" ]
    then
      rm -rf "${TMP_DIR}"
    fi
}

trap tearDown EXIT

echo "${SSH_PRIV_KEY}" > "${TMP_DIR}"/ssh_priv_key
chmod 0400 "${TMP_DIR}"/ssh_priv_key

# scp -i "${TMP_DIR}"/ssh_priv_key -vvv -o StrictHostKeyChecking=no "${WORKDIR}"/terraform/metadata "${SSH_USERNAME}"@jbx."${DNS%.}":~/tf_metadata 
DNS=$(jq -r .dns <"${WORKDIR}"/terraform/metadata)

# shellcheck disable=SC2002
ssh -i "${TMP_DIR}"/ssh_priv_key -vvv \
-o StrictHostKeyChecking=no \
-o UpdateHostKeys=no \
"${SSH_USERNAME}"@jbx."${DNS%.}" \
"BOSH_CIDR=$(jq -r .bosh_cidr <"${WORKDIR}"/terraform/metadata) \
BOSH_GW=$(jq -r .bosh_gw <"${WORKDIR}"/terraform/metadata) \
/home/${SSH_USERNAME}/deploy.sh"
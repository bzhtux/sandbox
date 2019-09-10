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

ls -lR "${WORKDIR}"/terraform/
BOSH_CIDR=$(jq -r .bosh_cidr <"${WORKDIR}"/terraform/metadata)
BOSH_GW=$(jq -r .bosh_gw <"${WORKDIR}"/terraform/metadata)
DNS=$(jq -r .dns <"${WORKDIR}"/terraform/metadata)

echo "${SSH_PRIV_KEY}" > "${TMP_DIR}"/ssh_priv_key

scp -o StrictHostKeyChecking=no -o UpdateHostKeys=no "${WORKDIR}"/bosh/scripts/deploy.sh -i "${TMP_DIR}"/ssh_priv_key "${SSH_USERNAME}"@jbx."${DNS}": 

ssh -i "${TMP_DIR}"/ssh_priv_key -o StrictHostKeyChecking=no -o UpdateHostKeys=no "${SSH_USERNAME}"@jbx."${DNS}" "\"${BOSH_CIDR} ${BOSH_GW}\""
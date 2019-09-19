#!/usr/bin/env bash

set -xeuo pipefail

# VARIABLES
WORKDIR=$PWD
TMP_DIR=$(mktemp -d /tmp/bosh.XXXXXX)
BOSH_GIT_URL="https://github.com/cloudfoundry/bosh-deployment.git"
BOSH_CIDR=$(jq -r .bosh_cidr <"${WORKDIR}"/terraform/metadata)
BOSH_GW=$(jq -r .bosh_gw <"${WORKDIR}"/terraform/metadata)
BOSH_IP="${BOSH_GW%.1}.10"
BOSH_SUBNET=$(jq -r .bosh_subnet <"${WORKDIR}"/terraform/metadata)
DNS=$(jq -r .dns <"${WORKDIR}"/terraform/metadata)
# CREDS=$(jq -r .gcp_json <"${WORKDIR}"/terraform/metadata)
CREDS=$(bosh int "${WORKDIR}"/terraform/metadata --path /gcp_json)
NET_NAME=$(jq -r .network_name <"${WORKDIR}"/terraform/metadata)
PROJECT_ID=$(echo "$CREDS" | jq -r .project_id)


# tearDown
tearDown(){
    if [ -d "${TMP_DIR}" ]
    then
      rm -rf "${TMP_DIR}"
    fi
}

trap tearDown EXIT

echo "$CREDS" > "${TMP_DIR}"/gcp_creds.json

# BOSH TUNNELING
echo "${SSH_PRIV_KEY}" > "${TMP_DIR}"/ssh_priv_key
chmod 0400 "${TMP_DIR}"/ssh_priv_key
export BOSH_ALL_PROXY="ssh+socks5://${SSH_USERNAME}@jbx.${DNS%.}:22?private-key=${TMP_DIR}/ssh_priv_key"

# GIT clone bosh-deployment sources
git clone "${BOSH_GIT_URL}" "${TMP_DIR}"/bosh

# BOSH create env
bosh delete-env "${TMP_DIR}"/bosh/bosh.yml \
--state "${WORKDIR}/state.json" \
--ops-file "${TMP_DIR}/bosh/gcp/cpi.yml" \
--ops-file "${TMP_DIR}/bosh/uaa.yml" \
--ops-file "${TMP_DIR}/bosh/credhub.yml" \
--ops-file "${TMP_DIR}/bosh/jumpbox-user.yml" \
--vars-store "${WORKDIR}/creds.yml" \
--var director_name=bosh \
--var internal_ip="${BOSH_IP}" \
--var internal_gw="${BOSH_GW}" \
--var internal_cidr="${BOSH_CIDR}" \
--var-file gcp_credentials_json="${TMP_DIR}/gcp_creds.json" \
--var network="${NET_NAME}" \
--var project_id="${PROJECT_ID}" \
--var subnetwork="${BOSH_SUBNET}" \
--var tags=[bosh-agent,ssh] \
--var zone="europe-west1-c"

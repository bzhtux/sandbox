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
TIMESTAMP=$(date +%s)

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

# GOBUILDCACHE
mkdir -p /tmp/.cache/go-build
export GOCACHE=/tmp/.cache/go-build

set +euo pipefail

scp -i "${TMP_DIR}"/ssh_priv_key -o StrictHostKeyChecking=no "${SSH_USERNAME}@jbx.${DNS%.}":~/.boshrc "${TMP_DIR}"/boshrc

if [ -f "${TMP_DIR}/boshrc" ]
then
  # shellcheck source=/dev/null
  . "${TMP_DIR}/boshrc"
fi

if timeout 5 bosh env
then
  echo > "${WORKDIR}/bosh-state/state-${TIMESTAMP}.json"
  echo > "${WORKDIR}/bosh-creds/creds-${TIMESTAMP}.yml"
  exit 0
fi

set -xeuo pipefail

# BOSH create env
GOCACHE=/tmp/.cache/go-build bosh create-env "${TMP_DIR}"/bosh/bosh.yml \
--state "${WORKDIR}/bosh-state/state-${TIMESTAMP}.json" \
--ops-file "${TMP_DIR}/bosh/gcp/cpi.yml" \
--ops-file "${TMP_DIR}/bosh/uaa.yml" \
--ops-file "${TMP_DIR}/bosh/credhub.yml" \
--ops-file "${TMP_DIR}/bosh/jumpbox-user.yml" \
--vars-store "${WORKDIR}/bosh-creds/creds-${TIMESTAMP}.yml" \
--var director_name=bosh \
--var internal_ip="${BOSH_IP}" \
--var internal_gw="${BOSH_GW}" \
--var internal_cidr="${BOSH_CIDR}" \
--var-file gcp_credentials_json="${TMP_DIR}/gcp_creds.json" \
--var network="${NET_NAME}" \
--var project_id="${PROJECT_ID}" \
--var subnetwork="${BOSH_SUBNET}" \
--var tags=[bosh,ssh] \
--var zone="europe-west1-c" \
--vars-env GOCACHE=/tmp/.cache/go-build

cat > boshrc <<EOF
export BOSH_CA_CERT="$(bosh int "${WORKDIR}/creds.yml" --path /director_ssl/ca)"
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=$(bosh int "${WORKDIR}/creds.yml" --path /admin_password)
export BOSH_ENVIRONMENT=${BOSH_IP}
EOF

scp -i "${TMP_DIR}"/ssh_priv_key -o StrictHostKeyChecking=no boshrc "${SSH_USERNAME}@jbx.${DNS%.}":~/.boshrc
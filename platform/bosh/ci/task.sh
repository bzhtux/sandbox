#!/usr/bin/env bash

set -xeuo pipefail

WORKDIR=$PWD
TMP_DIR=$(mktemp -d /tmp/bosh.XXXXXX)
BOSH_CIDR=$(jq -r .bosh_cidr <"${WORKDIR}"/terraform/metadata)
BOSH_GW=$(jq -r .bosh_gw <"${WORKDIR}"/terraform/metadata)
BOSH_SUBNET=$(jq -r .bosh_subnet <"${WORKDIR}"/terraform/metadata)
DNS=$(jq -r .dns <"${WORKDIR}"/terraform/metadata)
CREDS="$(jq -r .gcp_json <"${WORKDIR}"/terraform/metadata)"
# CREDS=$(bosh int "${WORKDIR}"/terraform/metadata --path /gcp_json)
NET_NAME=$(jq -r .network_name <"${WORKDIR}"/terraform/metadata)
PROJECT_ID=$(echo "$CREDS" | jq -r .project_id)
BOSH_GIT_URL="https://github.com/cloudfoundry/bosh-deployment.git"
TIMESTAMP=$(date +%s)
BOSH_IP="${BOSH_GW%.1}.10"
BOSH_VERSION="6.0.0"

# tearDown
tearDown(){
    if [ -d "${TMP_DIR}" ]
    then
      rm -rf "${TMP_DIR}"
    fi
}

trap tearDown EXIT  

echo "${SSH_PRIV_KEY}" > "${TMP_DIR}"/ssh_priv_key
chmod 0400 "${TMP_DIR}"/ssh_priv_key

echo "${CREDS}" > "${TMP_DIR}"/gcp_creds.json

# Generate BOSH create env shell script
cat > "${TMP_DIR}"/bosh.sh <<EOF
#!/usr/bin/env bash

set -xeuo pipefail

# VARIABLES
# TMP_DIR=$(mktemp -d /tmp/bosh.XXXXXX)
# BOSH_GIT_URL="https://github.com/cloudfoundry/bosh-deployment.git"
# BOSH_CIDR=${BOSH_CIDR}
# BOSH_GW=${BOSH_GW}
# BOSH_IP="${BOSH_GW%.1}.10"
# BOSH_SUBNET=${BOSH_SUBNET}
# DNS=${DNS}
# NET_NAME=${NET_NAME}
# PROJECT_ID=${PROJECT_ID}
# TIMESTAMP=$(date +%s)

# tearDown
tearDown(){
    if [ -d "${TMP_DIR}" ]
    then
      rm -rf "${TMP_DIR}"
    fi
}

trap tearDown EXIT  

# BOSH TUNNELING
# export BOSH_ALL_PROXY="ssh+socks5://${SSH_USERNAME}@jbx.${DNS%.}:22?private-key=${TMP_DIR}/ssh_priv_key"
BOSH_VERSION="6.0.0"
curl -L "https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64" -o /tmp/bosh
chmod +x /tmp/bosh 
sudo mv /tmp/bosh /usr/local/bin/


# APT
sudo apt update
sudo apt install -y curl \
golang-go \
make \
ruby


# GIT clone bosh-deployment sources
git clone "${BOSH_GIT_URL}" "${TMP_DIR}"/bosh

# GOBUILDCACHE
mkdir -p /tmp/.cache/go-build
export GOCACHE=/tmp/.cache/go-build

set +euo pipefail

if [ -f "/home/${SSH_USERNAME}/.boshrc" ]
then
  # shellcheck source=/dev/null
  . "/home/${SSH_USERNAME}/.boshrc"
fi

if timeout 5 bosh env
then
  echo > "${WORKDIR}/bosh-state/state-${TIMESTAMP}.json"
  echo > "${WORKDIR}/bosh-creds/creds-${TIMESTAMP}.yml"
  exit 0
fi

set -xeuo pipefail

if bosh create-env "${TMP_DIR}"/bosh/bosh.yml \
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
--var-file gcp_credentials_json="~/gcp_creds.json" \
--var network="${NET_NAME}" \
--var project_id="${PROJECT_ID}" \
--var subnetwork="${BOSH_SUBNET}" \
--var tags=[bosh,ssh] \
--var zone="europe-west1-c"
then
  export CA_CERT=$(bosh int "${WORKDIR}/bosh-creds/creds-*.yml" --path /director_ssl/ca)
  export SECRET=$(bosh int "${WORKDIR}/bosh-creds/creds-*.yml" --path /admin_password)
  cat > ~/.boshrc <<EOIF
export BOSH_CA_CERT=${CA_CERT}
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=${SECRET}
export BOSH_ENVIRONMENT=${BOSH_IP}
EOIF
fi

EOF


chmod +x "${TMP_DIR}"/bosh.sh

scp -i "${TMP_DIR}"/ssh_priv_key -o StrictHostKeyChecking=no "${TMP_DIR}"/gcp_creds.json "${SSH_USERNAME}@jbx.${DNS%.}:/home/${SSH_USERNAME}/gcp_creds.json"
scp -i "${TMP_DIR}"/ssh_priv_key -o StrictHostKeyChecking=no "${TMP_DIR}"/bosh.sh "${SSH_USERNAME}@jbx.${DNS%.}:/home/${SSH_USERNAME}/bosh.sh"
ssh -i "${TMP_DIR}"/ssh_priv_key -o StrictHostKeyChecking=no "${SSH_USERNAME}@jbx.${DNS%.}" "/home/${SSH_USERNAME}/bosh.sh"

scp -i "${TMP_DIR}"/ssh_priv_key -o StrictHostKeyChecking=no "${SSH_USERNAME}@jbx.${DNS%.}:${WORKDIR}/bosh-state/state-${TIMESTAMP}.json" "${WORKDIR}/bosh-state/state-${TIMESTAMP}.json"
scp -i "${TMP_DIR}"/ssh_priv_key -o StrictHostKeyChecking=no "${SSH_USERNAME}@jbx.${DNS%.}:${WORKDIR}/bosh-creds/creds-${TIMESTAMP}.yml" "${WORKDIR}/bosh-creds/creds-${TIMESTAMP}.yml"
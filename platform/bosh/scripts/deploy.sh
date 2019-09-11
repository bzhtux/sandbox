#!/usr/bin/env bash

TMP_DIR=$(mktemp -d /tmp/bosh.XXXXXX)
WORKDIR=$PWD
BOSH_VERSION="6.0.0"
BOSH_DL_URL="https://github.com/cloudfoundry/bosh-cli/releases/download/v${BOSH_VERSION}/bosh-cli-${BOSH_VERSION}-linux-amd64"
BOSH_GIT_URL="https://github.com/cloudfoundry/bosh-deployment.git"
if [ -z "${BOSH_CIDR}" ]
then
  BOSH_CIDR=$1
fi
if [ -z "${BOSH_GW}" ]
then
  BOSH_GW=$2
fi
TASKS=""
GREEN="\033[32m"
YELLOW="\033[33m"
EOC="\033[0m"

tearDown() {
  if [ -d "${TMP_DIR}" ]
  then
    rm -rf "${TMP_DIR}"
  fi
}

trap tearDown EXIT

if [ -f ".boshrc" ]
then
  source .boshrc
  if ! bosh env &>/dev/null
  then
    echo -e "${YELLOW}--- BOSH is not installed${EOC}"
    TASKS="install deploy"
  else
    echo -e "${GREEN}+++ BOSH already installed${EOC}"
  fi
else
  echo -e "${YELLOW}--- BOSH is not installed (no .boshrc file is present)${EOC}"
  installBosh
  TASKS="install deploy"
fi

set -euo pipefail

installBosh() {
  if [ ! -x "/usr/local/bin/bosh" ]
  then
    sudo curl -s -L "${BOSH_DL_URL}" -o /usr/local/bin/bosh || exit 1
    sudo chmod +x /usr/local/bin/bosh || exit 1
    echo -e "${GREEN}+++ BOSH successfully installed${EOC}"
  else
    echo -e "${GREEN}+++ BOSH binary /usr/local/bin/bosh already exists${EOC}"
  fi
}

deployBosh() {
  echo "+++ WIP: Deploy bosh "
  git clone "$BOSH_GIT_URL" "${TMP_DIR}"/bosh
  cd "${TMP_DIR}"
  BOSH_IP=$(echo ${BOSH_GW} | sed -e "s/\.1$/\.10$/g")
  bosh create-env "bosh/bosh.yml" \
    --state "${PWD}/state.json" \
    --ops-file "bosh/gcp/cpi.yml" \
    --ops-file "bosh/uaa.yml" \
    --ops-file "bosh/credhub.yml" \
    --ops-file "bosh/jumpbox-user.yml" \
    --vars-store "${PWD}/creds.yml" \
    --var director_name=bosh \
    --var internal_ip="${BOSH_IP}" \
    --var internal_gw="${BOSH_GW}" \
    --var internal_cidr="${BOSH_CIDR}" \
    # --var outbound_network_name=NatNetwork "$@"
  cd "${WORKDIR}"
}

for task in $TASKS
do
  case ${task} in
    deploy)
    deployBosh
    ;;
    install)
    installBosh
    ;;
    *)
    ;;
  esac
done
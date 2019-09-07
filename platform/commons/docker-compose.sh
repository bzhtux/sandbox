#!/usr/bin/env bash

WORKDIR=$PWD
TMP_DIR=$(mktemp -d /tmp/concourse.XXXXXX)
LOCAL_GIT="concourse-docker"
CI_TARGET="local"
CI_URL="http://localhost:8080"
CI_USER="test"
CI_PASS="test"

if [ -z "$1" ]
then
    echo "Usage: $0 <TASK>"
    echo
    echo "Tasks"
    echo "====="
    echo " - up"
    echo " - down"
    exit 1
else
    TASK=$1
fi

tearDown() {
    if [ "${TASK}" == "down" ]
    then
        docker-compose-down
    fi
    rm -rf "${TMP_DIR}"
}

trap tearDown EXIT

set -xeuo pipefail

checkLocalConcourse() {
    if ! fly -t ${CI_TARGET} login --concourse-url "${CI_URL}" -u "${CI_USER}" -p "${CI_PASS}" &>/dev/null
    then
        docker-compose-up
    fi
}

docker-compose-up() {
    cd "${TMP_DIR}/${LOCAL_GIT}" || exit 1
    docker-compose up -d
    cd "${WORKDIR}" || exit 1
}

docker-compose-down() {
    cd "${TMP_DIR}"/${LOCAL_GIT}/ || exit 1
    docker-compose stop
    docker-compose rm -f
    cd "${WORKDIR}" || exit 1
}


init() {
    git clone https://github.com/concourse/concourse-docker.git "${TMP_DIR}/${LOCAL_GIT}"
    cd "${TMP_DIR}/${LOCAL_GIT}" || exit 1
    ./keys/generate 
}

# MAIN
run() {
    init
    checkLocalConcourse
}

run
#!/usr/bin/env bash

set -x

WORKDIR=$PWD
LOCAL_GIT="concourse-docker"
CI_TARGET="local"
CI_URL="http://localhost:8080"
CI_USER="test"
CI_PASS="test"

if [ -z "$1" ] || [ -z "$2" ]
then
    echo "Usage: $0 <WORKDIR> <TASK>"
    echo
    echo "Tasks"
    echo "====="
    echo " - up"
    echo " - down"
    exit 1
else
    TMP_DIR=$1
    TASK=$2
fi

tearDown() {
    if [ "${TASK}" == "down" ]
    then
        docker-compose-down
    fi
}

trap tearDown EXIT

checkLocalConcourse() {
    if ! fly -t ${CI_TARGET} login -k -c "${CI_URL}" -u "${CI_USER}" -p "${CI_PASS}"
    then
        docker-compose-up
    fi
}

docker-compose-up() {
    cd "${TMP_DIR}/${LOCAL_GIT}" || exit 1
    ./keys/generate
    docker-compose up -d
    cd "${WORKDIR}" || exit 1
}

docker-compose-down() {
    cd "${TMP_DIR}"/${LOCAL_GIT}/ || exit 1
    docker-compose rm -s -f
    cd "${WORKDIR}" || exit 1
}


init() {
    git clone https://github.com/concourse/concourse-docker.git "${TMP_DIR}/${LOCAL_GIT}"
    cd "${TMP_DIR}/${LOCAL_GIT}" || exit 1
}

# MAIN
run() {
    init
    checkLocalConcourse
}

run
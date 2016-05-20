#! /bin/bash
#
# Copyright (c) 2016 Paulo Vital <pvital.solutions@yahoo.com>
#

# This script build Wok (https://github.com/kimchi-project/wok/) and its plugins
# Kimchi (https://github.com/kimchi-project/kimchi/),
# Ginger (https://github.com/kimchi-project/ginger/) and
# Gingerbase (https://github.com/kimchi-project/gingerbase/) in a temporary
# workspace and then run wokd server in development environment.

PROJECT_DIR="${HOME}/Projects"

function build {
    sleep 2
    make clean
    ./autogen.sh --system
    RC=$?
    [ ${RC} != 0 ] && { echo -e "Error during 'autogen.sh'. Exiting..."; exit 1; }

    make
    rc=$?
    [ ${RC} != 0 ] && { echo -e "Error during 'make'. Exiting..."; exit 1; }
}

function print_banner {
    echo -e "***************************************************"
    [ -n "${1}" ] && echo -e "***************** ${1}"
    echo -e "***************************************************"
}

# 1st stage - setup environment to wok's local repository and build it
DEST_DIR="/tmp"
[ ! -d ${DEST_DIR} ] && mkdir -p ${DEST_DIR}

# copy wok local repository
pushd ${DEST_DIR} > /dev/null 2>&1
[ -d wok_test ] && sudo rm -rf wok_test
cp -a ${PROJECT_DIR}/wok ./wok_test
TEST_DIR="${DEST_DIR}/wok_test"
popd > /dev/null 2>&1

# build wok
pushd ${TEST_DIR} > /dev/null 2>&1
print_banner "Building WOK..."
build
popd > /dev/null 2>&1

sleep 10

# 2nd stage - copy plugins local repositories to wok_test directory
for PLUGIN in ginger gingerbase kimchi; do
    # copy plugin local repository to wok_test
    pushd ${TEST_DIR}/src/wok/plugins > /dev/null 2>&1
    [ -d ${PLUGIN} ] && rm -rf ${PLUGIN}
    cp -a ${PROJECT_DIR}/${PLUGIN} ./
    popd > /dev/null 2>&1

    # build plugin
    pushd ${TEST_DIR}/src/wok/plugins/${PLUGIN} > /dev/null 2>&1
    print_banner "Building ${PLUGIN}..."
    build
    popd > /dev/null 2>&1
    sleep 5
done

# 3rd stage - run wokd
pushd ${TEST_DIR} > /dev/null 2>&1
print_banner "Starting Wok..."
if [ -e /var/lib/kimchi/objectstore ]; then
    # copy system's kimchi objectstore file to the test workspace
    mkdir -p ${TEST_DIR}/src/wok/plugins/kimchi/data
    sudo cp /var/lib/kimchi/objectstore ${TEST_DIR}/src/wok/plugins/kimchi/data/
fi
sudo ./src/wokd --environment=development
popd > /dev/null 2>&1

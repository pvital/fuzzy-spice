#! /bin/bash
#
# Copyright (c) 2016 Paulo Vital <pvital.solutions@yahoo.com>
#

# This script setup the development environment to all modules of Kimchi
# Project in a host system.
#
# Tested on Fedora 24 and RHEL7.2 (last update: 20160718)
#

PROJECT_DIR="${HOME}/Projects"

function print_banner () {
    echo -e "***************************************************"
    [ -n "$1" ] && echo -e "***************** $1"
    echo -e "***************************************************"
}

function my_exit () {
    echo -e "Something get wrong, quiting..."
    exit 1
}

function get_distro () {
    local DISTRO=""
    if [ -e /etc/os-release ]; then
        DISTRO=$(grep "^ID=" /etc/os-release | cut -d "=" -f2)
    else
        DISTRO="none"
    fi
    echo $DISTRO
}

function check_rhel_repos () {
    local ERR=0
    for REPO in epel server-optional; do
        RES=$(yum repolist | grep $REPO | wc -l)
        if [ $RES -eq 0 ]; then
            echo -e "Missing $REPO repository."
            ERR=$((ERR+1))
        fi
    done
    if [ $ERR -gt 0 ]; then
        my_exit
    fi
}

# 1st stage - install build and runtime dependencies

# WOK packages lists
WOK_BUILD_DEPS="gcc make autoconf automake gettext-devel git rpm-build libxslt"
WOK_RUN_DEPS="python-cherrypy python-cheetah PyPAM m2crypto python-jsonschema \
              python-psutil python-ldap python-lxml nginx openssl \
              open-sans-fonts fontawesome-fonts logrotate"
WOK_UI_DEVEL_DEPS="gcc-c++ python-devel python-pip"
WOK_TESTS_DEPS="pyflakes python-pep8 python-requests"

# GINGERBASE packages lists
GINGERB_RUN_DEPS="rpm-python sos pyparted python-configobj"

# KIMCHI packages lists
KIMCHI_RUN_DEPS="libvirt-python libvirt libvirt-daemon-config-network qemu-kvm \
                 python-ethtool sos python-ipaddr nfs-utils pyparted \
                 iscsi-initiator-utils python-libguestfs libguestfs-tools \
                 python-websockify novnc spice-html5 python-configobj \
                 python-magic python-paramiko python-pillow"
KIMCHI_TESTS_DEPS="python-mock"

# GINGER packages lists
GINGER_RUN_DEPS="hddtemp libuser-python python-augeas python-netaddr \
                 python-ethtool python-ipaddr python-magic tuned lm_sensors"

DISTRO=$( get_distro )
case $DISTRO in
    "fedora")
        PKG_MNG_CMD="dnf install -y"
        GINGERB_RUN_DEPS="$GINGERB_RUN_DEPS python2-dnf"
        ;;
    "\"rhel\"")
        # Check if additional repositories are enabled or not
        check_rhel_repos
        PKG_MNG_CMD="yum install -y"
        WOK_RUN_DEPS="$WOK_RUN_DEPS python-ordereddict"
        WOK_TESTS_DEPS="$WOK_TESTS_DEPS python-unittest2"
        ;;
    *)  my_exit;;
esac

${PKG_MNG_CMD} \
${WOK_BUILD_DEPS} ${WOK_RUN_DEPS} ${WOK_UI_DEVEL_DEPS} ${WOK_TESTS_DEPS} \
${GINGERB_RUN_DEPS} ${KIMCHI_RUN_DEPS} ${KIMCHI_TESTS_DEPS} ${GINGER_RUN_DEPS}

pip install cython libsass

# 2nd stage - clone source code
[ ! -d ${PROJECT_DIR} ] && mkdir -p ${PROJECT_DIR}

for PROJ in wok ginger gingerbase kimchi; do
    # clone each project into $PROJECT_DIR
    pushd ${PROJECT_DIR} > /dev/null 2>&1
    print_banner "Cloning ${PROJ} from GitHub ..."
    git clone https://github.com/pvital/${PROJ}.git
    popd > /dev/null 2>&1
    sleep 3
done

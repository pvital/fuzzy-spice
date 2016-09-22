#! /bin/bash
#
# Copyright (c) 2016 Paulo Vital <pvital.solutions@yahoo.com>
#

# This script setup the development environment to all modules of Kimchi
# Project in a host system.
#
# Tested on Fedora 24, Ubuntu 16.04, Debian 8.5 and CentOS 7
# (last update: 20160922)
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
    local REPOLIST="epel"
    if [ $( get_distro ) == "\"rhel\"" ]; then
        local REPOLIST="epel server-optional"
    fi
    for REPO in $REPOLIST; do
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

# distro's common packages lists for WOK
WOK_BUILD_DEPS="gcc make autoconf automake git"
WOK_RUN_DEPS="python-cheetah  python-jsonschema python-psutil python-ldap \
             python-lxml nginx openssl logrotate"
WOK_UI_DEVEL_DEPS="python-pip"
WOK_TESTS_DEPS="pyflakes python-requests"

# distro's common packages lists for GINGERBASE
GINGERB_RUN_DEPS="python-configobj"

# distro's common packages lists for KIMCHI
KIMCHI_RUN_DEPS="qemu-kvm python-ethtool python-ipaddr libguestfs-tools novnc \
                spice-html5 python-magic python-paramiko"
KIMCHI_TESTS_DEPS="python-mock"

# distro's common packages lists for GINGER
GINGER_RUN_DEPS="hddtemp python-augeas python-netaddr"

DISTRO=$( get_distro )
case $DISTRO in
    "fedora")
        PKG_MNG_CMD="dnf install -y"
        WOK_BUILD_DEPS="$WOK_BUILD_DEPS gettext-devel rpm-build libxslt"
        WOK_RUN_DEPS="$WOK_RUN_DEPS python-cherrypy PyPAM m2crypto  \
                     open-sans-fonts fontawesome-fonts"
        WOK_UI_DEVEL_DEPS="$WOK_UI_DEVEL_DEPS gcc-c++ python-devel"
        WOK_TESTS_DEPS="$WOK_TESTS_DEPS python-pep8"
        GINGERB_RUN_DEPS="$GINGERB_RUN_DEPS rpm-python sos pyparted python2-dnf"
        KIMCHI_RUN_DEPS="$KIMCHI_RUN_DEPS libvirt-python libvirt nfs-utils \
                        libvirt-daemon-config-network python-pillow \
                        iscsi-initiator-utils python-libguestfs \
                        python-websockify"
        GINGER_RUN_DEPS="$GINGER_RUN_DEPS libuser-python tuned lm_sensors"
        ;;
    "\"rhel\""|"\"centos\"")
        # Check if additional repositories are enabled or not
        check_rhel_repos
        PKG_MNG_CMD="yum install -y"
        WOK_BUILD_DEPS="$WOK_BUILD_DEPS gettext-devel rpm-build libxslt"
        WOK_RUN_DEPS="$WOK_RUN_DEPS python-cherrypy PyPAM m2crypto  \
                     open-sans-fonts fontawesome-fonts python-ordereddict"
        WOK_UI_DEVEL_DEPS="$WOK_UI_DEVEL_DEPS gcc-c++ python-devel"
        WOK_TESTS_DEPS="$WOK_TESTS_DEPS python-pep8 python-unittest2"
        GINGERB_RUN_DEPS="$GINGERB_RUN_DEPS rpm-python sos pyparted python2-dnf"
        KIMCHI_RUN_DEPS="$KIMCHI_RUN_DEPS libvirt-python libvirt nfs-utils \
                        libvirt-daemon-config-network python-pillow \
                        iscsi-initiator-utils python-libguestfs \
                        python-websockify"
        GINGER_RUN_DEPS="$GINGER_RUN_DEPS libuser-python tuned lm_sensors"
        ;;
    "ubuntu"|"debian")
        PKG_MNG_CMD="apt-get install -y"
        WOK_BUILD_DEPS="$WOK_BUILD_DEPS gettext pkgconf xsltproc"
        WOK_RUN_DEPS="$WOK_RUN_DEPS python-cherrypy3 python-pam \
                     python-m2crypto fonts-font-awesome texlive-fonts-extra"
        WOK_UI_DEVEL_DEPS="$WOK_UI_DEVEL_DEPS g++ python-dev"
        WOK_TESTS_DEPS="$WOK_TESTS_DEPS pep8"
        GINGERB_RUN_DEPS="$GINGERB_RUN_DEPS python-apt sosreport python-parted"
        KIMCHI_RUN_DEPS="$KIMCHI_RUN_DEPS websockify python-libvirt nfs-common \
                        libvirt-bin python-lxml open-iscsi python-guestfs"
        KIMCHI_TESTS_DEPS="$KIMCHI_TESTS_DEPS bc"
        GINGER_RUN_DEPS="$GINGER_RUN_DEPS python-libuser"
        ;;
    *) my_exit;;
esac

${PKG_MNG_CMD} \
${WOK_BUILD_DEPS} ${WOK_RUN_DEPS} ${WOK_UI_DEVEL_DEPS} ${WOK_TESTS_DEPS} \
${GINGERB_RUN_DEPS} ${KIMCHI_RUN_DEPS} ${KIMCHI_TESTS_DEPS} ${GINGER_RUN_DEPS}

pip install cython libsass

if [ ! -e /etc/libuser.conf ]; then
    touch /etc/libuser.conf
fi

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

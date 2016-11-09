#! /bin/bash
#
# Copyright (c) 2016 Paulo Vital <pvital.solutions@yahoo.com>
#

# This script set up the system to use IBM Java as default java solution.
#
# Tested on Fedora 24
# (last update: 201611009)


if [ ! -d /opt/ibm/java-x86_64-80 ]; then
    echo -e "IBM Java is not installed at /opt/ibm/java-x86_64-80. Quiting..."
    exit -1
fi


for BIN in java javaws javac jar; do
    alternatives --install /usr/bin/${BIN} ${BIN} /opt/ibm/java-x86_64-80/bin/${BIN} 200000
done


if [ $(uname -m) == "x86_64" ]; then

    ## Java Browser (Mozilla) Plugin 64-bit ##
    alternatives --install /usr/lib64/mozilla/plugins/libjavaplugin.so libjavaplugin.so.x86_64 /opt/ibm/java-x86_64-80/jre/lib/amd64/libnpjp2.so 200000
    ln -s /opt/ibm/java-x86_64-80/jre/lib/amd64/libnpjp2.so /usr/lib64/mozilla/plugins/libjavaplugin.so

else;

    ## Java Browser (Mozilla) Plugin 32-bit ##
    alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so libjavaplugin.so /opt/ibm/java-x86_64-80/jre/lib/i386/so.libnpjp2 200000
    ln -s /opt/ibm/java-x86_64-80/jre/lib/i386/so.libnpjp2 /usr/lib/mozilla/plugins/libjavaplugin.so

fi;

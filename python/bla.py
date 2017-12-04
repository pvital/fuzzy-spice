#!/usr/bin/python
#
# Copyright (c) 2016 Paulo Vital <pvital.solutions@yahoo.com>
#

import time

def search_01 (stdout=[]):
    package = {}
    if not ('package \'dnsmasq\' not found.') in stdout:
        for line in stdout:
            if line.startswith('Repository:'):
                package['repository'] = line.split(': ')[1].strip()
            if line.startswith('Version:'):
                package['version'] = line.split(': ')[1].strip()
            if line.startswith('Arch:'):
                package['arch'] = line.split(': ')[1].strip()
            if line.startswith('Name:'):
                package['package_name'] = line.split(': ')[1].strip()
    print package

def search_02 (stdout=[]):
    package = {}
    if not ('package \'dnsmasq\' not found.') in stdout:
        for (key, token) in (('repository', 'Repository:'),
                             ('version', 'Version:'),
                             ('arch', 'Arch:'),
                             ('package_name', 'Name:')):
            for line in stdout:
                if line.startswith(token):
                    package[key] = line.split(': ')[1].strip()
                    break
    print package

def search_03 (stdout=[]):
    package = {}
    if not ('package \'dnsmasq\' not found.') in stdout:
        package['repository'] = stdout[6].split(': ')[1].strip()
        package['package_name'] = stdout[7].split(': ')[1].strip()
        package['version'] = stdout[8].split(': ')[1].strip()
        package['arch'] = stdout[9].split(': ')[1].strip()
    print package

def main():
    stdout = ['Loading repository data...', 'Reading installed packages...',
              '', '', 'Information for package dnsmasq:',
              '--------------------------------',
              'Repository: Main Update Repository', 'Name: dnsmasq',
              'Version: 2.71-6.1', 'Arch: x86_64', 'Vendor: openSUSE',
              'Installed: Yes',
              'Status: out-of-date (version 2.71-4.2 installed)',
              'Installed Size: 1.1 MiB',
              'Summary: Lightweight, Easy-to-Configure DNS Forwarder and DHCP Server',
              'Description: ',
              '  Dnsmasq is a lightweight, easy-to-configure DNS forwarder and DHCP',
              '  server. It is designed to provide DNS and, optionally, DHCP, to a small',
              '  network. It can serve the names of local machines that are not in the',
              '  global DNS. The DHCP server integrates with the DNS server and allows',
              '  machines with DHCP-allocated addresses to appear in DNS with names',
              '  configured either in each host or in a central configuration file.',
              '  Dnsmasq supports static and dynamic DHCP leases and BOOTP for network',
              '  booting of diskless machines.',
              'Requires:', '  libc.so.6(GLIBC_2.14)(64bit)', '  /bin/bash',
              '  /usr/bin/perl', '  /usr/bin/python', '  libdbus-1.so.3()(64bit)',
              '  libgmp.so.10()(64bit)', '  libidn.so.11()(64bit)',
              '  libidn.so.11(LIBIDN_1.0)(64bit)', '  libnettle.so.4()(64bit)',
              '  libhogweed.so.2()(64bit)',
              '  libnetfilter_conntrack.so.3()(64bit)', '  /bin/sh',
              '  systemd', '  /usr/sbin/useradd', '  /bin/mkdir', '']

    print "*** Testing function 01..."
    t1 = time.time()
    search_01(stdout)
    t2 = time.time()
    print "Total time of execution is: ", (t2-t1)

    print "*** Testing function 02..."
    t1 = time.time()
    search_02(stdout)
    t2 = time.time()
    print "Total time of execution is: ", (t2-t1)

    print "*** Testing function 03..."
    t1 = time.time()
    search_03(stdout)
    t2 = time.time()
    print "Total time of execution is: ", (t2-t1)

if __name__ == "__main__":
   main()

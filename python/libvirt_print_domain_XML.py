#!/usr/bin/python
#
# Copyright (c) 2015 Paulo Vital <pvital.solutions@yahoo.com>
#

# This script prints the XML of a given DOMAIN_NAME or all current running
# domains using libvirt API. Also, it's possible to turn on libvirt events

import argparse
import libvirt
import threading

from wok.plugins.kimchi.model.featuretests import FeatureTests


def _event_loop_run():
    while True:
        libvirt.virEventRunDefaultImpl()


def process_args():
    parser = argparse.ArgumentParser(description='Print XML of libvirt domains')
    parser.add_argument('-c', '--capabilities', action='store_true',
                        help='Scan for host capabilities. Uses Kimchi\'s \
                              FeatureTests')
    parser.add_argument('-e', '--events', action='store_true',
                        help='Turn on libvirt\'s events handler')
    parser.add_argument('-d', '--domain', action='store', dest='domain_name',
                        default=None, help='Name of domain to print it\'s XML')
    parser.add_argument('--verbose', action='store_true',
                        help='Verbose mode')
    return parser.parse_args()


def print_domain_xml(domain):
    xml = domain.XMLDesc(libvirt.VIR_DOMAIN_XML_INACTIVE)
    print "XML for VM ", domain.name()
    print xml


def debug(msg="", flag=False):
    if not flag:
        return
    print "**** " + msg

def _set_capabilities(conn=False):
    debug("Running feature tests. This can take a while.", True)
    if not conn:
        return
    qemu_stream = FeatureTests.qemu_supports_iso_stream()
    nfs_target_probe = FeatureTests.libvirt_support_nfs_probe(conn)
    fc_host_support = FeatureTests.libvirt_support_fc_host(conn)
    kernel_vfio = FeatureTests.kernel_support_vfio()
    nm_running = FeatureTests.is_nm_running()
    mem_hotplug_support = FeatureTests.has_mem_hotplug_support(conn)

    libvirt_stream_protocols = []
    for p in ['http', 'https', 'ftp', 'ftps', 'tftp']:
        if FeatureTests.libvirt_supports_iso_stream(conn, p):
            libvirt_stream_protocols.append(p)
    debug("Feature tests completed.", True)
_set_capabilities.priority = 90

def main(args):
    if args.events:
        debug("Turning on libvirt\'s events handler.", args.verbose)
        libvirt.virEventRegisterDefaultImpl()
        event_loop_thread = threading.Thread(target=_event_loop_run,
                                             name="EventLoop")
        event_loop_thread.setDaemon(True)
        event_loop_thread.start()

    # Open a connection with libvirt
    conn = libvirt.open('qemu:///system')

    if args.capabilities:
        debug("Scanning for host capabilities.", args.verbose)
        _set_capabilities(conn)

    if args.domain_name != None:
        debug("Printing XML for given domain.", args.verbose)
        domain = conn.lookupByName(args.domain_name)
        print_domain_xml(domain)
        return

    debug("No given DOMAIN_NAME. Looking for running domains...", args.verbose)
    domain_ids = conn.listDomainsID()
    if len(domain_ids) < 1:
        print "No given DOMAIN_NAME or running domain at this moment. Exiting."
        return

    for id in domain_ids:
        domain = conn.lookupByID(id)
        print_domain_xml(domain)
        print "==========================================================="

if __name__ == "__main__":
   main(process_args())

#!/usr/bin/python
#
# Copyright (c) 2016 Paulo Vital <pvital.solutions@yahoo.com>
#

# This script define, create and prints the XML of a given DOMAIN_NAME or all
# current running domains using libvirt API. Also, it's possible to turn on
# libvirt events

import argparse
import libvirt
import platform


ISO_STREAM_XML = """
<domain type='%(domain)s'>
  <name>%(name)s</name>
  <memory unit='MiB'>256</memory>
  <os>
    <type arch='%(arch)s'>hvm</type>
    <boot dev='cdrom'/>
  </os>
  <devices>
    <disk type='network' device='cdrom'>
      <driver name='qemu' type='raw'/>
      <source protocol='%(protocol)s' name='/url/path/to/iso/file'>
        <host name='host.name' port='1234'/>
      </source>
      <target dev='hdc' bus='ide'/>
      <readonly/>
      <alias name='ide0-1-0'/>
      <address type='drive' controller='0' bus='1' target='0' unit='0'/>
    </disk>
  </devices>
</domain>"""


def process_args():
    parser = argparse.ArgumentParser(description='Print XML of libvirt domains')
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


def main(args):
    # Open a connection with libvirt
    conn = libvirt.open('qemu:///system')

    if args.domain_name == None:
        debug("No given DOMAIN_NAME. Using the name \'TEST_VM\'", args.verbose)
        args.domain_name = 'TEST_VM'

    debug("Looking for %s in the current domains list..." % args.domain_name,
          args.verbose)
    try:
        domain = conn.lookupByName(args.domain_name)
        if domain:
            print "Domain %s already exist. Exiting..." % args.domain_name
            return -1
    except libvirt.libvirtError as e:
        pass

    conn_type = conn.getType().lower()
    domain_type = 'test' if conn_type == 'test' else 'kvm'
    arch = 'i686' if conn_type == 'test' else platform.machine()
    arch = 'ppc64' if arch == 'ppc64le' else arch
    dom = None
    try:
        debug("Defining domain %s" % args.domain_name, args.verbose)
        dom = conn.defineXML(ISO_STREAM_XML % {'name': args.domain_name,
                                               'domain': domain_type,
                                               'protocol': 'http',
                                               'arch': arch})
        debug("Starting %s" % args.domain_name, args.verbose)
        dom.create()
        print_domain_xml(dom)
    except libvirt.libvirtError as e:
        print e
        return -1
    finally:
        debug("Shuting down domain %s" % args.domain_name, args.verbose)
        if (dom is not None and dom.isActive() == 1): dom.destroy()
        debug("Undefining domain %s" % args.domain_name, args.verbose)
        dom is None or dom.undefine()
    return


if __name__ == "__main__":
   main(process_args())

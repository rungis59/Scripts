#!/usr/bin/env python
#
# ldap-inventory.py
# Dynamic inventory script for Microsoft LDAP
# Razique Mahroua <rmahroua@redhat.com>
#
# Copyright 2019 Red Hat, Inc.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#    1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above
#    copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials provided
#    with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY RED HAT, INC. ``AS IS'' AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL RED HAT, INC. BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

#################################
#   Configuration settings      #
#################################

# FQDN of the AD server
AD_SERVER_NAME          = 'windc.example.com'

# Used by NTLM for authentication - must be the domain minus the suffix
NTLM_AUTH_DOMAIN       = 'EXAMPLE'
# DN to use to perform the query
AD_DN                  = 'dc=example,dc=com'

# User name & password for connection
AD_USERNAME             = 'student'
AD_PASSWORD             = 'RedHat123@!'

# The script will put all hosts in this group
INVENTORY_DEFAULT_GROUP = 'Windows'

######################## DO NOT EDIT BELOW THIS LINE ###########################
import argparse
import json
import sys

try:
    from ldap3 import Server,Connection, ALL, NTLM, ALL_ATTRIBUTES, ALL_OPERATIONAL_ATTRIBUTES, AUTO_BIND_NO_TLS, SUBTREE
    from ldap3.core.exceptions import LDAPCursorError
except:
    print('')
    print('    Python LDAP3 library is missing!')
    print('    Try "yum install python2-ldap3"')
    print('    If using Python 3, try "yum install python36-ldap3"')
    print('')
    exit(1)


parser = argparse.ArgumentParser(
    description='Python script that returns the list of hosts in an LDAP inventory.'
)
# Declares positional arguments
parser.add_argument(
    '-l', '--list',
    action = 'store_false',
    dest   = "list",
    help   = "Returns a JSON-encoded hash or dictionary containing all the groups."
)
parser.add_argument(
    '--host',
    dest   = "host",
    help   = "Returns a JSON hash/dictionary of <host> passed as parameter."
)
parser.add_argument(
    '--output',
    dest   = "output",
    help   = "Use 'json' for JSON output or 'table' for table output."
)

args = parser.parse_args()

# Establish initial connection
server = Server(AD_SERVER_NAME, get_info = ALL)
conn   = Connection(
    server,
    user           = '{}\\{}'.format(NTLM_AUTH_DOMAIN, AD_USERNAME),
    password       = AD_PASSWORD,
    authentication = NTLM,
    auto_bind      = True
)

# Run search
if args.host:
    conn.search(
        '{}'.format(AD_DN),
        '(&(objectCategory=computer)(name=' + str(args.host).lower() + '))',
        attributes=[
            ALL_ATTRIBUTES, ALL_OPERATIONAL_ATTRIBUTES
        ]
    )
    single_host = {}
else:
    conn.search('{}'.format(AD_DN),
        '(objectclass=computer)',
        attributes=[
            ALL_ATTRIBUTES, ALL_OPERATIONAL_ATTRIBUTES
        ]
    )

    hosts = {}
    hosts['all'] = { 'children': [] }
    hosts['ungrouped'] = { 'hosts': []}
    hosts["_meta"] = { 'hostvars': {}}
    hosts[INVENTORY_DEFAULT_GROUP] = {}
    hosts[INVENTORY_DEFAULT_GROUP]['children'] = []
    hosts[INVENTORY_DEFAULT_GROUP]['hosts'] = []
    hosts['all']['children'].append(INVENTORY_DEFAULT_GROUP)

i = 0

if args.output == 'table':
    format_string = '{:25} {:>6} {:19} {:19} {}'
    print(format_string.format(
          'Server',
          'Logins',
          'Last Login',
          'Expires',
          'Description'
        )
    )

for e in conn.entries:
    try:
        desc = e.description
    except LDAPCursorError:
        desc = ""

    if args.output == 'table':
        print(
            format_string.format(str(e.name),
            str(e.logonCount),
            str(e.lastLogon)[:19],
            str(e.accountExpires)[:19],
            desc)
        )
    else:
        # For a list of available attributes, run the following command
        # dsquery * -filter "&(objectClass=Computer) \
        # (sAMAccountName=<computer>$)" -attr *
        if args.host:
            single_host['canonical_name']     = str(e.cn)
            try:
                single_host['creation_date']  = str(e.whenCreated)
            except LDAPCursorError:
                pass

            try:
                single_host['DNS_Name']       = str(e.dNSHostName)
            except LDAPCursorError:
                pass

            try:
                single_host['group_id']       = str(e.primaryGroupID)
            except LDAPCursorError:
                pass

            try:
                single_host['GUID']           = str(e.objectGUID)
            except LDAPCursorError:
                pass

            try:
                single_host['last_login']     = str(e.lastLogon).lower()
            except LDAPCursorError:
                pass

            try:
                single_host['login_count']    = str(e.logonCount).lower()
            except LDAPCursorError:
                pass

            try:
                single_host['name']           = str(e.name)
            except LDAPCursorError:
                pass

            try:
                single_host['OS_Version']     = str(e.operatingSystemVersion)
            except LDAPCursorError:
                pass

            try:
                single_host['OS']             = str(e.operatingSystem)
            except LDAPCursorError:
                pass

            try:
                single_host['SID']            = str(e.objectSid)
            except LDAPCursorError:
                pass

        else:
            try:
                hosts[INVENTORY_DEFAULT_GROUP]['hosts'].append(str(e.dNSHostName).lower())
            except LDAPCursorError:
                hosts[INVENTORY_DEFAULT_GROUP]['hosts'].append(str(e.name).lower() + AD_DN.replace('dc=', '.', -1).replace(',', '', -1))

    i =+ 1

if args.host:
    json_data = json.dumps(single_host, indent=4)
else:
    json_data = json.dumps(hosts, indent=4)

if args.output != 'table':
    print(json_data)
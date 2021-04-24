ipa.md
===

# System Accounts

https://www.freeipa.org/page/HowTo/LDAP#System_Accounts

# Add system account to a role 

```
[oleksii@bo01-vm-ipa01 ~]$ cat sys_ldap-add-to-role.ldif 
dn: cn=helpdesk,cn=roles,cn=accounts,dc=noroutine,dc=me
changetype: modify
add: member
member: uid=sys_ldap,cn=sysaccounts,cn=etc,dc=noroutine,dc=me

###
ldapmodify -f sys_ldap-add-to-role.ldif 
```

# Upgrade

```
yum check-update
yum update
```

Cleanup
```
yum clean all
```

# POSIX DNA ranges
https://www.redhat.com/archives/freeipa-users/2015-May/msg00517.html

After migration DNA ragnes are lost if no new users are created on new masters

https://www.freeipa.org/page/V3/Recover_DNA_Ranges

```
ipa-replica-manage dnarange-set bo01-vm-ipa01.noroutine.me 897000005-897000099
ipa-replica-manage dnanextrange-set bo01-vm-ipa01.noroutine.me 897000101-897000199
```

# Migrate ipa to another cluster

## Setup new nodes as replicas

## Run backup on old nodes
```
ipa-backup
```
## Promote Master CA on new cluster
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/linux_domain_identity_authentication_and_policy_guide/moving-crl-gen-old

```
# Check which ipa instance is current Master CA
ipa config-show

# Change to new 
ipa config-mod --ca-renewal-master-server bo01-vm-ipa01.noroutine.me
```

## Enable CRL generation on new Master CA

You may want to also disable CRL generation on old master CA

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/linux_domain_identity_authentication_and_policy_guide/server-roles#promote-change-crl-gen

```
ipa-crlgen-manage status
ipa-crlgen-manage enable
```

Make sure the /var/lib/ipa/pki-ca/publish/MasterCRL.bin file exists on the new master CA server.

## Migrate DNSSEC Key master
https://www.freeipa.org/page/Howto/DNSSEC#Migrate_DNSSEC_master_to_another_IPA_server

```
# Check which ipa instance is current Master CA
ipa config-show

# Disable DNSSEC on current key master, use the --force to skip checking DNSSEC for existing zones
ipa-dns-install --disable-dnssec-master --force

# Copy key db backup to new key master

# Enable new dnssec master with copied db
ipa-dns-install --dnssec-master \
    --kasp-db=/home/oleksii/ipa-kasp.db.backup \
    --forwarder=10.0.10.1 \
    --reverse-zone=10.in-addr.arpa

# Verify that new DNSSEC key master is active
ipa config-show

```

## Change authoritative name server in all zones to a server from new cluster

```
ipa dnszone-find

ipa dnszone-mod --name-server bo01-vm-ipa01.noroutine.me. lab05.noroutine.me
ipa dnszone-mod --name-server bo01-vm-ipa01.noroutine.me. lab04.noroutine.me
ipa dnszone-mod --name-server bo01-vm-ipa01.noroutine.me. lab03.noroutine.me
ipa dnszone-mod --name-server bo01-vm-ipa01.noroutine.me. lab02.noroutine.me
ipa dnszone-mod --name-server bo01-vm-ipa01.noroutine.me. lab01.noroutine.me
ipa dnszone-mod --name-server bo01-vm-ipa01.noroutine.me. dmz01.noroutine.me
ipa dnszone-mod --name-server bo01-vm-ipa01.noroutine.me. bo01.noroutine.me

```

## Validate topology

In UI or comand-line, make sure new servers are interconnected in the topology

## Remove ipa server from topology

```
# on another server
ipa server-del ipa02.noroutine.me
```

## Uninstall ipa server on old nodes

```
```
### Command-line
```
topologysegment-find
```

### In UI

IPA Server > Topology > Topology Graph

https://bo01-vm-ipa01.noroutine.me/ipa/ui/#/p/topology-graph


# Server install

yum -y install @idm:DL1

ipa-server-install --unattended --uninstall

ipa-server-install --unattended \
    --realm=NOROUTINE.ME \
    --ds-password Passw0rd \
    --admin-password Passw0rd \
    --mkhomedir \
    --hostname=ipa01.noroutine.me \
    --no-host-dns \
    --ip-address=10.0.21.12 \
    --no-ntp \
    --ssh-trust-dns \
    --setup-dns \
    --domain=noroutine.me \
    --forwarder=10.0.21.1 \
    --no-dnssec-validation \
    --reverse-zone=10.in-addr.arpa \
    --allow-zone-overlap \
    --external-ca \
    --external-ca-type=generic \
    --ca-subject="CN=IPA CA,OU=HQ,O=Noroutine GmbH,L=Munich,ST=Bayern,C=DE" \
    --subject-base="DC=noroutine,DC=me" \
    --ca-signing-algorithm=SHA256withRSA
```
    --forwarder=10.0.21.1

openssl ca -config openssl.conf -extensions v3_intermediate_ca_loose -policy policy_loose -days 730 -notext -md sha256 -in csr/ipa_lab01.noroutine.me.csr.pem -out certs/ipa_lab01.noroutine.me.crt.pem

ipa-server-install --unattended \
    --realm=NOROUTINE.ME \
    --ds-password Passw0rd \
    --admin-password Passw0rd \
    --mkhomedir \
    --hostname=ipa01.noroutine.me \
    --ip-address=10.0.21.12 \
    --no-ntp \
    --ssh-trust-dns \
    --setup-dns \
    --domain=noroutine.me \
    --forwarder=10.0.21.1 \
    --no-dnssec-validation \
    --reverse-zone=10.in-addr.arpa \
    --allow-zone-overlap \
    --external-ca \
    --external-cert-file=/root/ipa.crt.pem \
    --external-ca-type=generic \
    --ca-subject="CN=IPA CA,OU=HQ,O=Noroutine GmbH,L=Munich,ST=Bayern,C=DE" \
    --subject-base="DC=noroutine,DC=me" \
    --ca-signing-algorithm=SHA256withRSA

# User principlal aliasing
# Use own Intermediate CA
```
    --external-ca \
    --external-ca-type=generic \

  Certificate system options:
    --external-ca       Generate a CSR for the IPA CA certificate to be signed
                        by an external CA
    --external-ca-type={generic,ms-cs}
                        Type of the external CA
    --external-ca-profile=EXTERNAL_CA_PROFILE
                        Specify the certificate profile/template to use at the
                        external CA
    --external-cert-file=FILE
                        File containing the IPA CA certificate and the
                        external CA certificate chain
    --subject-base=SUBJECT_BASE
                        The certificate subject base (default O=<realm-name>).
                        RDNs are in LDAP order (most specific RDN first).
    --ca-subject=CA_SUBJECT
                        The CA certificate subject DN (default CN=Certificate
                        Authority,O=<realm-name>). RDNs are in LDAP order
                        (most specific RDN first).
    --ca-signing-algorithm={SHA1withRSA,SHA256withRSA,SHA512withRSA}
                        Signing algorithm of the IPA CA certificate
```

Be sure to back up the CA certificates stored in /root/cacert.p12
These files are required to create replicas. The password for these
files is the Directory Manager password

# Replica setup

ipa-client-install \
    --unattended \
    --principal sys_enroll \
    --password="3nr0l1ME!" \
    --mkhomedir \
    --no-ntp \
    --domain=noroutine.me \
    --realm=NOROUTINE.ME \
    --ssh-trust-dns \
    --force-join

# Manually create DNS A record for host if it doesn't exist after ipa-client-install

ipa hostgroup-add-member ipaservers --hosts ipa01.noroutine.me
ipa hostgroup-add-member ipaservers --hosts ipa02.noroutine.me
ipa hostgroup-add-member ipaservers --hosts ipa03.noroutine.me

ipactl stop
ipa-replica-manage list
ipa-replica-manage del ipa02.lab01.noroutine.me --force

ipa-replica-install \
    --setup-dns \
    --setup-ca \
    --forwarder=10.0.10.1 \
    --reverse-zone=10.in-addr.arpa \
    --no-dnssec-validation

ipa-dns-install \
    --forwarder=10.0.21.99 \
    --no-dnssec-validation \
    --auto-reverse

# DNSSEC

https://www.freeipa.org/page/Howto/DNSSEC

# Backup and Restore

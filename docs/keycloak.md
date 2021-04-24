keycloak.md
===

# User federation

Mapping first-name = givenName

Username LDAP attribute 
uid
* RDN LDAP attribute 
uid
* UUID LDAP attribute 
ipaUniqueID
* User Object Classes 
inetOrgPerson, organizationalPerson
* Connection URL 
ldap://bo01-vm-ipa01.noroutine.me:389/
* Users DN 
dc=noroutine,dc=me
Custom User LDAP Filter 
LDAP Filter
Search Scope 

Subtree
* Bind Type 

simple
* Bind DN 
uid=sys_ldap,cn=sysaccounts,cn=etc,dc=noroutine,dc=me
* Bind Credential 

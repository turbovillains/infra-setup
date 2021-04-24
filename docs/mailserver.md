Mail
===

# Test with Curl

```
scheme://user:password;options@in.example.com
```

```
TEST_USER=test_mail@noroutine.us
TEST_PASS=abbfjotld
TEST_CREDS=${TEST_USER}:${TEST_PASS}
TEST_SMTP_OPTS="--mail-rcpt ${TEST_USER} --mail-from ${TEST_USER}"

curl -v -u ${TEST_CREDS} ${TEST_SMTP_OPTS} smtp://lab01-mailserver.service.lab01.noroutine.me
curl -v -u ${TEST_CREDS} ${TEST_SMTP_OPTS} smtps://lab01-mailserver.service.lab01.noroutine.me
curl -v -u ${TEST_CREDS} ${TEST_SMTP_OPTS} --ssl-reqd smtp://lab01-mailserver.service.lab01.noroutine.me

curl -v -u ${TEST_CREDS} imap://lab01-mailserver.service.lab01.noroutine.me
curl -v -u ${TEST_CREDS} imaps://lab01-mailserver.service.lab01.noroutine.me
curl -v -u ${TEST_CREDS} --ssl-reqd imap://lab01-mailserver.service.lab01.noroutine.me
```

# Test auth in container

https://doc.dovecot.org/admin_manual/debugging/debugging_authentication/

Dovecot
```
doveadm auth test test_mail@noroutine.us abbfjotld
```

SASL

```
testsaslauthd -u test_mail -p abbfjotld -r noroutine.us
```

Postfix

```
postmap -q test_mail@noroutine.us ldap:/etc/postfix/ldap-users.cf
```
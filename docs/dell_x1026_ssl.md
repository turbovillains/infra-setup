Install SSL certificate on Dell X1026
===

# In exec mode

```
crypto certificate 2 request cn sw01.noroutine.me or "Noroutine GmbH" ou HQ loc Munich st Bayern cu DE
```

# Sign the request

# in config mode

```
configure
crypto certificate 2 import
ip https certificate 2
exit
wr
```
nextcloud.md
===

## Config

https://docs.nextcloud.com/server/20/admin_manual/configuration_server/index.html

Config file is sensitive and should not be overwritten

## Locked files

https://help.nextcloud.com/t/file-is-locked-how-to-unlock/1883


## Delete files on server

Delete, then run file scan:
```
php occ files:scan --all
```

## Pretty links

https://kenfavors.com/code/enabling-pretty-links-in-nextcloud/

## SSL CA bundle for PHP

https://www.php.net/manual/en/function.openssl-get-cert-locations.php

## Default Mail Account Settings

https://help.nextcloud.com/t/settings-mail-app/24398/2
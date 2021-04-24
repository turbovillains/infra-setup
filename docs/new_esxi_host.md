New esxi host

networking
iscsi adapter

### add iqn to iscsi spezi

```
/iscsi/iqn.2017-11.me.noroutine:drbd/tpg1/acls
create add_mapped_luns=true wwn=iqn.1998-01.com.vmware:esxi02-307c24db

/iscsi/iqn.2017-11.me.noroutine:hq.nix/tpg1/acls
create add_mapped_luns=true wwn=iqn.1998-01.com.vmware:esxi02-307c24db

```

### add iqn to iscsi limo
```
/iscsi/iqn.2017-11.me.noroutine:drbd/tpg1/acls
create add_mapped_luns=true wwn=iqn.1998-01.com.vmware:esxi02-307c24db

/iscsi/iqn.2017-11.me.noroutine:hq.nix/tpg1/acls
```

Add dynamic discovery targets:

10.255.254.10:3260
10.255.255.10:3260

10.255.254.99:3260
10.255.255.99:3260

10.255.254.100:3260
10.255.255.100:3260

Rescan adapter 

Make sure that on DRBD device 10.255.254.10 path is active by default (should be the same on all hosts)
You can disable wrong path temporarily and enable it again later to force desired active path

Make sure that any other path except 10.255.255.10 or 10.255.254.10 on DRBD device is disabled.

Make sure that DRBD device uses MRU policy

Make sure that host-specific datastores have round-robin policy for best performance

Make sure all datastores are mounted, investigate if not, mount them persistently

```
esxcfg-volume -M PRO
```



Disable smartd

```
/etc/init.d/smartd stop
chkconfig smartd off
```

Disable SuppressHyperthreadWarning warning

Make sure SSH service is enabled to start with host


Configure syslog server

```
esxcli system syslog config set --loghost='tcp://10.0.7.4:514'  --logdir=/scratch/log
esxcli system syslog reload
```

Configure NTP servers

10.0.7.38,10.0.7.39
UserVars.SupressShellWarning = 1
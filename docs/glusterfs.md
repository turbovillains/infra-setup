glusterfs.md
===

# CTDB 

This should be 0 if using CTDB, otherwise releaseip fails, as CTDB thinks ip is still present 
https://github.com/sYnfo/samba/blob/6a369cfe25b8c84f87aaf093a44089303b1b3793/ctdb/common/system_common.c#L49
```
net.ipv4.ip_nonlocal_bind=0
```
# Samba config

https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.3/html/administration_guide/sect-smb
https://docs.gluster.org/en/latest/Administrator%20Guide/Accessing%20Gluster%20from%20Windows/

# Ports

24007 – Gluster Daemon
24008 – Management
24009 and greater (GlusterFS versions less than 3.4) OR
49152 (GlusterFS versions 3.4 and later) – Each brick for every volume on your host requires it’s own port. For every new brick, one new port will be used starting at 24009 for GlusterFS versions below 3.4 and 49152 for version 3.4 and above. If you have one volume with two bricks, you will need to open 24009 – 24010 (or 49152 – 49153).
38465 – 38467 – this is required if you by the Gluster NFS service.


# XFS is preferred over ext4

maxpct for arbiter node should be higher (like 25% or even more)

# Some reference guides used

## GlusterFS + NFS (no ganesha)
https://jamesnbr.wordpress.com/2017/01/26/glusterfs-and-nfs-with-high-availability-on-centos-7/

## Articles from Rackspace on glusterfs

https://support.rackspace.com/how-to/glusterfs-troubleshooting/
https://support.rackspace.com/how-to/glusterfs-high-availability-through-ctdb/

## Samba CTDB guide (kernel NFS + CTDB, no specific cluster fs)

https://wiki.samba.org/index.php/Setting_up_CTDB_for_Clustered_NFS

## CTDB callouts

From: https://wiki.samba.org/index.php/Advanced_CTDB_configuration

CTDB runs event scripts when certain events occur. These event scripts usually reside in the events/ subdirectory of the CTDB configuration directory. This is often /etc/ctdb/events.

Event scripts support health monitoring, service management, IP failover, internal CTDB operations and features. They handle events such as startup, shutdown, monitor, releaseip and takeip.

Please see the event scripts that installed by CTDB for examples of how to configure other services to be aware of the HA features of CTDB.

Also see ctdb/config/events/README in the Samba source tree for additional documentation on how to write and modify event scripts.

### storhaug
https://github.com/gluster/storhaug/blob/master/nfs-ganesha-callout

### CTDB

https://github.com/samba-team/samba/blob/master/ctdb/doc/examples/nfs-ganesha-callout

There is some latest version of 60.ganesha, that is i suppose event handler from CTDB

https://github.com/SpectraLogic/samba/blob/master/ctdb/config/events.d/60.ganesha


More on CTDB
https://wiki.samba.org/index.php/CTDB_and_Clustered_Samba
https://wiki.samba.org/index.php/Configuring_clustered_Samba

## Red Hat Gluster Storage <3.5 guide (ganesha)

gluster-nfs and nfs-ganesha cannot run together


### Adding and Removing Export Entries Dynamically

https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3/html/administration_guide/sect-nfs#sect-NFS_Ganesha

## Red Hat Gluster Storage <3.5 guide (ctdb + glusterfs + kernel NFS)
https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3/html/administration_guide/sect-configuring_automated_ip_failover_for_nfs_and_smb

## Red Hat Gluster Storage 3.5 guide (ganesha + glusterfs + pacemaker)

https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.5/html/administration_guide/nfs#nfs_ganesha

# storhaug

Deos some bash magic with dbus to notify ganesha 
https://github.com/gluster/storhaug


# Filehandles are not uniform

Different device id

```
root@lab02-vm-nfs03:/home/oleksii# onnode all stat -c '%d:%i' /mnt/testfile

>> NODE: 10.0.22.31 <<
49:12593768994775710782

>> NODE: 10.0.22.32 <<
48:12593768994775710782

>> NODE: 10.0.22.33 <<
48:12593768994775710782
```

# Prepare brick

When creating replica and arbiter logical volumes, make sure to use same number of inodes across bricks

mkfs.xfs maxpct ??
mkfs.ext4 -N nnn

# Create volume

```
gluster volume create vol02 \
    replica 2 arbiter 1 transport tcp \
    lab02-vm-nfs01:/glusterfs/bricks/vol02 \
    lab02-vm-nfs02:/glusterfs/bricks/vol02 \
    lab02-vm-nfs03:/glusterfs/bricks/vol02 \
    force

gluster volume start vol02
```

# Extend GlusterFS volume

Simple extend the volumes on all nodes

https://stackoverflow.com/a/55791173

```
lvextend --resizefs -L+50G /dev/data-vg/nexus-replica 
```

## docs

Ensure shared storage is enabled
```
gluster volume set all cluster.enable-shared-storage enable
```

```

Prepare mount points, volumes and mount them

onnode all mkdir /data/gluster/docs/brick

# Make sure arbiter is third node
gluster volume create docs \
    replica 2 arbiter 1 transport tcp \
    10.0.8.9:/data/gluster/docs/brick \
    10.0.8.10:/data/gluster/docs/brick \
    10.0.8.4:/data/gluster/docs/brick

gluster volume start docs

gluster volume info docs

# Verify twix is an arbiter
```

## git

Ensure shared storage is enabled
```
gluster volume set all cluster.enable-shared-storage enable
```

```

Prepare mount points, volumes and mount them

onnode all mkdir /data/gluster/git/brick

# Make sure arbiter is third node
gluster volume create git \
    replica 2 arbiter 1 transport tcp \
    10.0.8.9:/data/gluster/git/brick \
    10.0.8.10:/data/gluster/git/brick \
    10.0.8.4:/data/gluster/git/brick

gluster volume start git

gluster volume info git

# Verify twix is an arbiter
```

## nexus

Ensure shared storage is enabled
```
gluster volume set all cluster.enable-shared-storage enable
```

```

Prepare mount points, volumes and mount them

onnode all mkdir /data/gluster/nexus/brick

# Make sure arbiter is third node
gluster volume create nexus \
    replica 2 arbiter 1 transport tcp \
    10.0.8.9:/data/gluster/nexus/brick \
    10.0.8.10:/data/gluster/nexus/brick \
    10.0.8.4:/data/gluster/nexus/brick

gluster volume start nexus

gluster volume info nexus

# Verify twix is an arbiter
```

## bo01

Ensure shared storage is enabled
```
gluster volume set all cluster.enable-shared-storage enable
```

```

Prepare mount points, volumes and mount them

onnode all mkdir /data/gluster/env/bo01/brick

# Make sure arbiter is third node
gluster volume create bo01 \
    replica 2 arbiter 1 transport tcp \
    10.0.8.9:/data/gluster/env/bo01/brick \
    10.0.8.10:/data/gluster/env/bo01/brick \
    10.0.8.4:/data/gluster/env/bo01/brick

gluster volume start bo01

gluster volume info bo01

# Verify twix is an arbiter
```


## lab01

Ensure shared storage is enabled
```
gluster volume set all cluster.enable-shared-storage enable
```

```

Prepare mount points, volumes and mount them

onnode all mkdir /data/gluster/env/lab01/brick

# Make sure arbiter is third node
gluster volume create lab01 \
    replica 2 arbiter 1 transport tcp \
    10.0.8.9:/data/gluster/env/lab01/brick \
    10.0.8.10:/data/gluster/env/lab01/brick \
    10.0.8.4:/data/gluster/env/lab01/brick

gluster volume start lab01

gluster volume info lab01

# Verify twix is an arbiter
```

## lab02

Ensure shared storage is enabled
```
gluster volume set all cluster.enable-shared-storage enable
```

```

Prepare mount points, volumes and mount them

onnode all mkdir /data/gluster/env/lab02/brick

# Make sure arbiter is third node
gluster volume create lab02 \
    replica 2 arbiter 1 transport tcp \
    10.0.8.9:/data/gluster/env/lab02/brick \
    10.0.8.10:/data/gluster/env/lab02/brick \
    10.0.8.4:/data/gluster/env/lab02/brick

gluster volume start lab02

gluster volume info lab02

# Verify twix is an arbiter
```

## lab03

Ensure shared storage is enabled
```
gluster volume set all cluster.enable-shared-storage enable
```

```

Prepare mount points, volumes and mount them

onnode all mkdir /data/gluster/env/lab03/brick

# Make sure arbiter is third node
gluster volume create lab03 \
    replica 2 arbiter 1 transport tcp \
    10.0.8.9:/data/gluster/env/lab03/brick \
    10.0.8.10:/data/gluster/env/lab03/brick \
    10.0.8.4:/data/gluster/env/lab03/brick

gluster volume start lab03

gluster volume info lab03

# Verify twix is an arbiter
```

## lab04

Create 20G bricks
```
twix#   lvcreate -n lab04-arbiter -l 1280 int-gw03-vg
limo#   lvcreate -n lab04-replica -l 5120 data-vg
spezi#  lvcreate -n lab04-replica -l 5120 data-vg
```

Create FS on bricks with exactly same number of inodes


```
twix#   mkfs.ext4 -N 1310720 /dev/int-gw03-vg/lab04-arbiter
spezi#  mkfs.ext4 -N 1310720 /dev/data-vg/lab04-replica
limo#   mkfs.ext4 -N 1310720 /dev/data-vg/lab04-replica
```

Use below to check existing volume as a reference and look at `Inode count`
```
tune2fs -l <device>
```

Add volumes to fstab on all three nodes and mount

```
twix:

/dev/mapper/int--gw03--vg-lab04--arbiter  /data/gluster/env/lab04     ext4    errors=remount-ro 0 1

spezi/limo:

/dev/mapper/data--vg-lab04--replica  /data/gluster/env/lab04     ext4    errors=remount-ro 0 1
```

Mount it
```
any#   onnode all mkdir /data/gluster/env/lab04
any#   onnode all mount /data/gluster/env/lab04
```

Ensure shared storage is enabled
```
gluster volume set all cluster.enable-shared-storage enable
```

```

Prepare mount points, volumes and mount them

onnode all mkdir /data/gluster/env/lab04/brick

# Make sure arbiter is third node
gluster volume create lab04 \
    replica 2 arbiter 1 transport tcp \
    10.0.8.9:/data/gluster/env/lab04/brick \
    10.0.8.10:/data/gluster/env/lab04/brick \
    10.0.8.4:/data/gluster/env/lab04/brick

gluster volume start lab04

gluster volume info lab04

# Verify twix is an arbiter
```
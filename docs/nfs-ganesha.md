nfs-ganesha.md
===

# ID mapping can cause weird uids, avoid using local user accounts

https://www.suse.com/support/kb/doc/?id=000017244

Can be disabled??

https://wiki.archlinux.org/index.php/NFS#Enabling_NFSv4_idmapping

# Config file reference

https://github.com/nfs-ganesha/nfs-ganesha/blob/master/src/config_samples/config.txt

# Enable shared storage 

https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.1/html/administration_guide/chap-managing_red_hat_storage_volumes-shared_volume

```
gluster volume set all cluster.enable-shared-storage enable
```

# RPC fixed ports

Q. Is this required for ganesha? Probably yes for ports, what about statsd callout

A. Actually no as per http://sniansfblog.org/the-advantages-of-nfsv4-1/
NFSv4 uses a single port number by mandating the server will listen on port 2049. There are no “auxiliary” protocols like statd, lockd and mountd required as the mounting and locking protocols have been incorporated into the NFSv4 protocol. This means that NFSv4 clients do not need to contact the portmapper, and do not need to access services on floating ports.

So fixed ports are required for NFSv3 only

Clustering NFS has some extra requirements compared to running a regular NFS server, so some extra configuration is needed.

All NFS RPC services should run on fixed ports, which should be the same on all cluster nodes. Some clients can become confused if ports change during fail-over.
NFSv4 should be disabled.
statd should be configured to use CTDB's high-availability call-out.
The NFS_HOSTNAME variable must be set in the NFS system configuration. This configuration is loaded by CTDB's high-availability call-out, which uses NFS_HOSTNAME. NFS_HOSTNAME should be resolvable into the CTDB public IP addresses that are used by NFS clients.
statd's hostname (passed via the -H option) must use the value of NFS_HOSTNAME.

https://wiki.samba.org/index.php/Setting_up_CTDB_for_Clustered_NFS#Selecting_fixed_ports_for_NFS_RPC_services

statd
mountd
rquotad
lockd


# Create ganesha HA config

Data coherency across the multi-head NFS-Ganesha servers in the cluster is achieved using the Gluster’s Upcall infrastructure. Gluster’s Upcall infrastructure is a generic and extensible framework that sends notifications to the respective glusterfs clients (in this case NFS-Ganesha server) when changes are detected in the back-end file system.

https://staged-gluster-docs.readthedocs.io/en/release3.7.0beta1/Features/upcall/

Pacemaker or ctdb can be used

upcall is still in use for NFSv4 to maintine some shared state 

https://sourceforge.net/p/nfs-ganesha/mailman/message/34144368/


## Sample ganesha-ha.conf file

This is part of RH configuration and is likely geared for RH8 and pacemaker

```
# Name of the HA cluster created.
# must be unique within the subnet
HA_NAME="ganesha-ha-360"
#
# The gluster server from which to mount the shared data volume.
HA_VOL_SERVER="localhost"
#
# You may use short names or long names; you may not use IP addresses.
# Once you select one, stay with it as it will be mildly unpleasant to clean up if you switch later on. Ensure that all names - short and/or long - are in DNS or /etc/hosts on all machines in the cluster.
#
# The subset of nodes of the Gluster Trusted Pool that form the ganesha HA cluster. Hostname is specified.
HA_CLUSTER_NODES="lab02-vm-nfs01.node.lab02.noroutine.me,lab02-vm-nfs02.node.lab02.noroutine.me,lab02-vm-nfs03.node.lab02.noroutine.me"
#HA_CLUSTER_NODES="server1.lab.redhat.com,server2.lab.redhat.com,..."
#
# Virtual IPs for each of the nodes specified above.
VIP_server1="VIP_SERVER1"
VIP_server2="VIP_SERVER2"
#VIP_server1.lab.redhat.com="10.0.2.1"
#VIP_server2.lab.redhat.com="10.0.2.2"
```

# Enable ganesha support in gluster ???

https://access.redhat.com/documentation/en-us/red_hat_gluster_storage/3.1/html/administration_guide/sect-nfs#sect-NFS_Ganesha

```
gluster nfs-ganesha enable
```

???
```
gluster volume set <volname> ganesha.enable on
```
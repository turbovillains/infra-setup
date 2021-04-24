storage failover notes
===
# Post-recovery check-list

- Only path to DRBD datastore that goes via VIP is enabled, others are disabled on all hosts
- No dead paths in any host
- Both vips are on same node
- Only one path is active on every host
- both drbd sides are primary and in sync
- both are exported via lun with same serial id
- storage rescan was done
- all vms are accessible and running
- datastore is mounted on all hosts

# Move iscsi ips
```
ctdb moveip 10.255.255.10 0
ctdb moveip 10.255.254.10 0
```

```
ctdb moveip 10.255.255.10 1
ctdb moveip 10.255.254.10 1
```

# Get serial number of LIO iscsi block device
```
 cat /sys/kernel/config/target/core/iblock_0/drbd0/wwn/vpd_unit_serial
T10 VPD Unit Serial Number: 5e4a7085-42ed-40b7-bb59-fe3a66226191
```

# Create drbd resource

```
drbdadm create-md
drbdadm up 
```

Resize drbd resource

during resize or other modifications, only one node should be primary
```
# on both
lvresize -l +488380 /dev/spezi-datastore/spezi-nvme05-pm983-drbd0-r0
lvresize -l +488380 /dev/limo-datastore/limo-nvme01-pm983-drbd0-r0 

# on primary
drbdadm resize  -- --assume-clean resize r0
```

# CTDB
for ctdb this option may prevent undesired ip rebalancing NoIPFailback

# speed up resync

```
drbdadm disk-options --c-plan-ahead=0

drbdadm disk-options --resync-rate=700M --c-max-rate=700M --c-plan-ahead=0 --c-fill-target=24M --c-min-rate=80M --disk-barrier=no  --disk-flush-no r0
drbdadm net-options --max-buffers=100k --sndbuf-size=4M --rcvbuf-size=4M r0
```

this made the biggest impact on sync rate
```
drbdadm disk-options --resync-rate=700M --c-max-rate=700M --c-plan-ahead=0 --c-fill-target=24M --c-min-rate=600M --disk-barrier=no  --disk-flushes=no r0
```

`--c-min-rate` was adjusted to 600M and sync speed immediately improved

```
drbdadm adjust all # revert to conf settings

drbdsetup show /dev/drbd0
```

# recover failed node

```
drbdadm disconnect all
drbdadm secondary all
drbdadm -- --discard-my-data connect all
```

# recover from split-brain

https://www.recitalsoftware.com/blogs/29-howto-resolve-drbd-split-brain-recovery-manually

on backup
```
# drbdadm secondary resource 
# drbdadm disconnect resource
# drbdadm -- --discard-my-data connect resource
```

on survivor

```
# drbdadm connect resource
```
You may omit this step if the node is already in the WFConnection state; it will then reconnect automatically.

If all else fails and the machines are still in a split-brain condition then on the secondary (backup) machine issue:

```
drbdadm invalidate resource
```

# LIO target steps
```
targetcli /backstores/block create dev=/dev/drbd0 name=drbd0

echo "5e4a7085-42ed-40b7-bb59-fe3a66226191" > /sys/kernel/config/target/core/iblock_0/drbd0/wwn/vpd_unit_serial

targetcli /iscsi/iqn.2017-11.me.noroutine:drbd/tpg1/luns/ create lun=0 storage_object=/backstores/block/drbd0

targetcli /iscsi/iqn.2017-11.me.noroutine:drbd/tpg1/luns/ delete lun=0
```
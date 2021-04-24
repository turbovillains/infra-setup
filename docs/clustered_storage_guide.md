Clustered Storage (NFSv4 and SMB)
===

Big instruction

# NFS Ganesha + GlusterFS cluster step-by-step

install gluster
install ganesha
install ctdb (same can be possible with pacemaker, but didn't test)
confgure glusterfs shared volume
create clustered volume
create ganesha exports for volume
disable idmapping (if sys is used)
disable NFSv4 delegations

configure ctdb (nodes, public addresses, onapp)
configure ctdb callout script for ganesha monitoring
configure ctdb callout script to use gluster shared storage volume 
configure ctdb recovery lock to deal with split brain


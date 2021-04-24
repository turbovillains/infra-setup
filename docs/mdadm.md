mdadm.md
===

```
md0 flash pro
lrwxrwxrwx 1 root root    9 Mar  9 21:52 ata-Samsung_SSD_850_PRO_1TB_S2BBNWAJ207927E -> ../../sdf
lrwxrwxrwx 1 root root    9 Mar  9 21:52 ata-Samsung_SSD_850_PRO_1TB_S2BBNWAJ207930D -> ../../sdg

mdadm --create --verbose --level raid1 --raid-devices=2 --metadata=1.2 --assume-clean /dev/md0 /dev/sdf1 /dev/sdg1

md2 flash evo
lrwxrwxrwx 1 root root    9 Mar  9 21:52 ata-Samsung_SSD_850_EVO_1TB_S3PLNF0J907525E -> ../../sdi
lrwxrwxrwx 1 root root    9 Mar  9 21:52 ata-Samsung_SSD_850_EVO_1TB_S3PLNF0J907526L -> ../../sdh

mdadm --create --verbose --level raid1 --raid-devices=2 --metadata=1.2 --assume-clean /dev/md2 /dev/sdi1 /dev/sdh1

md1
lrwxrwxrwx 1 root root    9 Mar  9 21:52 ata-Samsung_SSD_860_EVO_1TB_S3Z9NB0K601776M -> ../../sde
lrwxrwxrwx 1 root root   10 Mar  9 21:52 ata-Samsung_SSD_860_EVO_1TB_S3Z9NB0K601776M-part1 -> ../../sde1
lrwxrwxrwx 1 root root    9 Mar  9 21:52 ata-Samsung_SSD_860_EVO_1TB_S3Z9NB0K601784B -> ../../sdd
lrwxrwxrwx 1 root root   10 Mar  9 21:52 ata-Samsung_SSD_860_EVO_1TB_S3Z9NB0K601784B-part1 -> ../../sdd1

md3

lrwxrwxrwx 1 root root    9 Mar  9 21:52 ata-HGST_HUH721010ALE604_7PG2YBXR -> ../../sdb
lrwxrwxrwx 1 root root    9 Mar  9 21:52 ata-HGST_HUH721010ALE604_7PGT1K8C -> ../../sdc

```

# Find arrays
```
mdadm --examine --scan --verbose
```

# Assemble array with new name 
```
sudo mdadm --assemble /dev/md0 --name limo.noroutine.me:0 --update=name /dev/sde1 /dev/sdd1
```
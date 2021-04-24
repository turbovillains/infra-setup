storage.md
===

# Info about dm-XYZ devices

```
dmsetup info /dev/dm-3
```
```
sudo lvdisplay|awk  '/LV Name/{n=$3} /Block device/{d=$3; sub(".*:","dm-",d); print d,n;}'
```

# Translate disk to ata number

```
ls -l /sys/block/sd* \
| sed -e 's^.*-> \.\.^/sys^' \
       -e 's^/host^ ^'        \
       -e 's^/target.*/^ ^'   \
| while read Path HostNum ID
  do
     echo ${ID}: $(cat $Path/host$HostNum/scsi_host/host$HostNum/unique_id)
  done
 ```

# Find SATA link speeds

```
#!/bin/sh
# findstatlink.sh : This script is contributed by Shawn Hicks at
# https://www.cyberciti.biz/faq/linux-command-to-find-sata-harddisk-link-speed/#comment-114440
# ------
for i in `grep -l Gbps /sys/class/ata_link/*/sata_spd`; do
 echo Link "${i%/*}" Speed `cat $i`
 cat "${i%/*}"/device/dev*/ata_device/dev*/id | perl -nE 's/([0-9a-f]{2})/print chr hex $1/gie' | echo "    " Device `strings` | cut -f 1-3
done
```
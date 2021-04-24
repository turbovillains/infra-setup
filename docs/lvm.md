lvm.md
===

# Break mirror back into linear
https://www.thegeekdiary.com/centos-rhel-7-how-to-create-and-remove-the-lvm-mirrors-using-lvconvert/

```
lvconvert /dev/root-vg/root-lv -m0 /dev/sdh5
vgreduce root-vg /dev/sdh5
pvremove /dev/sdh5
```
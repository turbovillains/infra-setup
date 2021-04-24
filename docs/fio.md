fio
===

```
[global]
bs=128K
iodepth=128
direct=1
ioengine=libaio
group_reporting
time_based
runtime=600
numjobs=4
name=raw-randreadwrite
rw=randrw
rwmixwrite=95
size=1G

[job]
```



gl-mifi.md
===

Start/stop openvpn client

```
/etc/init.d/startvpn
```

Hostname 

```
uci show system.@system[0].hostname
uci set system.@system[0].hostname=gl-mifi
uci commit
```

List interfaces

```
ubus list network.interface.*
```


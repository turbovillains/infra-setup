network.md
===

# Public IPs

185.93.174.1			vip int-gw01m/int-gw02m
185.93.174.2			int-gw01m
185.93.174.3			int-gw02m
185.93.174.4			outgoing NAT IP

185.93.174.9			lab03 nginx ingress
185.93.174.10			dmz01 lb01 // decommissioned

185.93.174.11			ns1	// lab03 powerdns
185.93.174.12			ns2 // lab03 powerdns
185.93.174.13			ns3 // lab03 powerdns

185.93.174.31			mailu // 10.0.23.46
185.93.174.32			unused // 10.0.23.47

185.93.174.41			cam01

185.93.174.125			public vs

95.179.162.63			ext-gw01
95.179.238.64			ext-gw02
209.250.250.126			ext-gw03


# Public Networks

```
add area=backbone network=185.93.174.0/24
add area=backbone network=188.116.50.0/24
add area=backbone network=188.116.51.0/24
```
# Current vlans

```
[admin@int-gw02m] /interface vlan> print 
Flags: X - disabled, R - running 
 #   NAME                  MTU ARP             VLAN-ID INTERFACE               
 0 R bo                   1500 enabled              10 bond1                   
 1 R dev                  1500 enabled              12 bond1                   
 2 R dmz01                1500 enabled              14 bond1                   
 3 R eden                 1500 enabled              11 bond1                   
 4 R home-wifi            1500 enabled               5 bond1                   
 5 R ipsec-dmz            1500 enabled               3 bond1                   
 6 R k8s01                1500 enabled              27 bond1                   
 7 R k8s02                1500 enabled              28 bond1                   
 8 R lab01                1500 enabled              21 bond1                   
 9 R lab02                1500 enabled              22 bond1                   
10 R lab03                1500 enabled              23 bond1                   
11 R lab04                1500 enabled              24 bond1                   
12 R lab05                1600 enabled              25 bond1                   
13 R mgmt                 1500 enabled               7 bond1                   
14 R nfs                  1500 enabled               8 bond1                   
15 R pacific-wm-edge-tep  1600 enabled              42 bond1                   
16 R pacific-wm-esxi-tep  1600 enabled              41 bond1                   
17 R public-185           1500 enabled             185 bond1                   
18 R test01               1500 enabled              31 bond1                   
19 R vsphere-ha           1500 enabled              13 bond1   
```

# Currently used networks

10.0.0.0/16			headquarters (covered by above VLAN table)
10.0.55.0/24        extra wifi network on int-gw03+ap02
10.10.1.0/24		vultr / ext-gw01 / frankfurt
10.10.2.0/24    	vultr / ext-gw02 / london
10.12.1.0/24		openvpn backdoor
10.11.1.0/24        vultr / ext-gw01 / frankfurt / ipsec
10.11.2.0/24        vultr / ext-gw02 / london / ipsec
192.168.178.0/24	fritzbox DSL
192.168.177.0/24    fritzbox LTE
169.254.0.0/24      ad-hoc p2p tunnels

## P2P tunnels

169.254.1.0/30 ext-gw01 tun1		tunnel to int-gw01m
169.254.1.4/30 ext-gw02 tun1		tunnel to int-gw01m
169.254.1.8/30 ext-gw01 tun2		tunnel to int-gw02m
169.254.1.12/30 ext-gw02 tun2		tunnel to int-gw02m
169.254.1.16/30 ext-gw01 tun0		tunnel between ext-gw01 and ext-gw02

169.254.1.20/30 ext-gw02 tun3		tunnel to ap03
169.254.1.24/30 ext-gw01 tun3		tunnel to ap03

169.254.1.28/30	ext-gw03 tun1		tunnel to int-gw01m
169.254.1.32/30	ext-gw03 tun2		tunnel to int-gw02m

169.254.1.36/30 ext-gw01 tun4  ext-gw02 tun5       tunnel between ext-gw01 and ext-gw02
169.254.1.40/30 ext-gw02 tun4  ext-gw03 tun5       tunnel between ext-gw02 and ext-gw03
169.254.1.44/30 ext-gw03 tun4  ext-gw01 tun5       tunnel between ext-gw03 and ext-gw01


# Networks that have access to internet 

```
-A POSTROUTING -s 10.0.5.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.1.5.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.0.7.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.0.10.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.0.11.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.0.12.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.0.14.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.0.21.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.0.22.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.0.23.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.0.24.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.0.25.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.12.1.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.11.1.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 10.11.2.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 169.254.1.0/24 -o ens3 -j MASQUERADE
-A POSTROUTING -s 192.168.178.0/24 -o ens3 -j MASQUERADE
```

# Add new VLAN

- Add vlan with description to sw01/sw02
- Add vlan interface on int-gw01m/int-gw02m

```
/interface vlan
add interface=bond1 name=nfs vlan-id=8
```
- Add vrrp interface on int-gw02m/int-gw02m

```
/interface vrrp
add interface=nfs name=nfs-vip priority=200 vrid=2 # for int-gw01m
add interface=nfs name=nfs-vip priority=100 vrid=2 # for int-gw02m
```
- Assign addresses

```
# int-gw01m
/ip address
add address=10.0.8.2/24 interface=nfs

# int-gw02m
/ip address
add address=10.0.8.3/24 interface=nfs

# on both
/ip address
add address=10.0.8.1/24 interface=nfs-vip

```

- Verify all three addresses are up
- Verify all new network is routed via ospf

```
/routing ospf route print where dst-address=10.0.8.0/24
```
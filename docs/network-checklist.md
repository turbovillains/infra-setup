Big Network Checklist
===

# Basic Connectivity

## Internet

* int-gw01 to fritzbox01, ext-gw01, ext-gw02, 1.1.1.1, 1.1.1.2, 1.1.1.3, 1.1.1.4
* int-gw02 to fritzbox02, ext-gw01, ext-gw02, 1.1.1.1, 1.1.1.2, 1.1.1.3, 1.1.1.4
* bo01 to fritzbox01
* bo01 to fritzbox02
* home-wifi to fritzbox01
* home-wifi to fritzbox02

## Vultr

### External access
* int-gw01m to ext-gw01
* int-gw01m to ext-gw02
* int-gw02m to ext-gw01
* int-gw02m to ext-gw02

### IPSec

* int-gw01m to 10.10.1.1, 10.10.2.1
* int-gw02m to 10.10.1.1, 10.10.2.1
* 10.10.1.1 to 10.10.2.1
* 10.10.2.1 to 10.10.1.1



[cloud](https://cloud.noroutine.me/) | [website](https://noroutine.me/)

#### `dmz01`
* [Consul](https://consul.service.dmz01.noroutine.me:8501/) | [Nomad](https://nomad.service.dmz01.noroutine.me:4646/)

#### `bo01` Prod / Infra
* [Consul](https://consul.service.bo01.noroutine.me:8501/) | [Vault](https://vault.service.bo01.noroutine.me:8200/) | [Traefik](http://bo01-traefik.service.bo01.noroutine.me:8080/) | [Traefik Internet](http://bo01-traefik-internet.service.bo01.noroutine.me:8080/) | [Nomad](https://nomad.service.bo01.noroutine.me:4646/)
* [Prometheus](https://prometheus.bo01.noroutine.me/)
* [minio](https://minio.bo01.noroutine.me/) | [keycloak](https://keycloak.bo01.noroutine.me/)

#### `lab01` Staging
* [Consul](https://consul.service.lab01.noroutine.me:8501/) | [Vault](https://vault.service.lab01.noroutine.me:8200/) | [Traefik](http://lab01-traefik.service.lab01.noroutine.me:8080/) | [Traefik Internet](http://lab01-traefik-internet.service.lab01.noroutine.me:8080/) | [Nomad](https://nomad.service.lab01.noroutine.me:4646/)
* [Prometheus](https://prometheus.lab01.noroutine.me/)
* [minio](https://minio.lab01.noroutine.me/) | [keycloak](https://keycloak.lab01.noroutine.me/)

#### `lab02` Data Science Lab
* [Consul](https://consul.service.lab02.noroutine.me:8501/) | [Traefik](http://lab02-traefik.service.lab02.noroutine.me:8080/) | [Nomad](https://nomad.service.lab02.noroutine.me:4646/)
* [Prometheus](http://lab02-prometheus.service.lab02.noroutine.me:9090/)
* [Broccoli](https://broccoli.lab02.noroutine.me/)
* [Zeppelin](https://zeppelin-ui.lab02.noroutine.me/) | [Zeppelin Spark](https://zeppelin-spark-ui.lab02.noroutine.me/)
* [Spark Master](https://spark-master-web-ui.lab02.noroutine.me/) | [Spark Worker](https://spark-worker-web-ui.lab02.noroutine.me/)

#### `lab03`
* [shell](https://shell.lab03.noroutine.me/)
* [Grafana](https://grafana.lab03.noroutine.me/) | [Kibana](https://kibana.lab03.noroutine.me/) | [Alerta](https://alerta.lab03.noroutine.me/)
* [Prometheus Root](https://prometheus-root.lab03.noroutine.me/) | [Prometheus](https://prometheus.lab03.noroutine.me/) | [Alertmanager](https://alertmanager.lab03.noroutine.me/)
* [hello](https://hello.lab03.noroutine.me/) | [speedtest](https://speedtest.lab03.noroutine.me/) | [httpbin](https://httpbin.lab03.noroutine.me/) | [kubeapps](https://apps.lab03.noroutine.me/)
* [Kibana](https://kibana.lab03.noroutine.me/)
* [ArgoCD](https://argocd,lab03.noroutine.me/)

#### `lab04`
* [hello](https://hello.lab04.noroutine.me/) | [apps](https://apps.lab04.noroutine.me/)


[Overview](https://grafana.bo01.noroutine.me/d/KBKwe-9Zz/overview?orgId=1&refresh=1m) | [Network](https://grafana.bo01.noroutine.me/d/jfBUD99Zz/network?orgId=1&refresh=5s) | [Storage](https://grafana.bo01.noroutine.me/d/KNvEBPrZz/storage?orgId=1&refresh=5s) | [IPMI](https://grafana.lab01.noroutine.me/d/YI90nsLMk/ipmi?orgId=1&refresh=5s)

#### `infra`
* [Git](https://bo01-vm-git01.node.bo01.noroutine.me/) | [Nexus](https://bo01-vm-nexus01.node.bo01.noroutine.me/) | [IPA](http://bo01-vm-ipa01.noroutine.me/) | [twix](https://twix.noroutine.me/)

#### `vmware`

* [vcsa](https://vcsa.noroutine.me/) | [vcsa vApp](https://vcsa.noroutine.me:5480/)
* [nsx](https://nsx.noroutine.me/)
* [sm01a](https://esxi-sm01a.noroutine.me/) | [sm01b](https://esxi-sm01b.noroutine.me/) | [sm01c](https://esxi-sm01c.noroutine.me/) | [sm01d](https://esxi-sm01d.noroutine.me/)
* [sm02a](https://esxi-sm02a.noroutine.me/) | [sm02b](https://esxi-sm02b.noroutine.me/) | [sm02c](https://esxi-sm02c.noroutine.me/) | [sm02d](https://esxi-sm02d.noroutine.me/)
* [esxi03](https://esxi03.noroutine.me/)

#### `ikvm`
* [sm01a](https://sm01a-ikvm.noroutine.me/) | [sm01b](https://sm01b-ikvm.noroutine.me/) | [sm01c](https://sm01c-ikvm.noroutine.me/) | [sm01d](https://sm01d-ikvm.noroutine.me/)
* [sm02a](https://sm02a-ikvm.noroutine.me/) | [sm02b](https://sm02b-ikvm.noroutine.me/) | [sm02c](https://sm02c-ikvm.noroutine.me/) | [sm02d](https://sm02d-ikvm.noroutine.me/)
* [esxi03](https://esxi03-ikvm.noroutine.me/)

#### `network`
* [laserjet](http://laserjet.noroutine.me/)
* [fritzbox01 (DSL)](https://fritzbox01.noroutine.me/) | [fritzbox02 (LTE)](https://fritzbox02.noroutine.me/)
* [sw01](https://sw01.noroutine.me/) | [sw02](https://sw02.noroutine.me/)
* [sw-xg01](https://sw-xg01.noroutine.me/) | [sw-xg02](https://sw-xg02.noroutine.me/)
* [int-gw01m](https://int-gw01m.noroutine.me/) | [int-gw02m](https://int-gw02m.noroutine.me/)
* [int-gw01](https://int-gw01.noroutine.me/) | [int-gw02](https://int-gw02.noroutine.me/)
* [ap01](https://ap01.noroutine.me) | [ap02](https://ap02.noroutine.me) | [ap03](https://ap03.noroutine.me)

#### `camera`

* [cam01](https://cam01.noroutine.me)


#### Allianz
* [Allianz Services](https://allianz-agn-en.webex.com/allianz-agn/j.php?MTID=m543278cc096ffeb67bf399b9c889c20c)
* [Allianz Support](https://allianz-agn-en.webex.com/allianz-agn/j.php?MTID=mdbfe81ed0bb1a702d5cfe8deffa58d7d)
* [Services Board](https://jira.gda.allianz/secure/RapidBoard.jspa?rapidView=136&view=detail&selectedIssue=DSP-8870&quickFilter=323)

#### Noroutine
* [daily](https://zoom.us/j/95609791508?pwd=UStYZlQ2VHpLdGhvdURrU1VPSDJ2Zz09 )
* [pipeline](https://www.meistertask.com/app/project/q8bNNk3Y/pipeline) |  [templates](https://cloud.noroutine.me/index.php/f/729)
* [drill](https://www.meistertask.com/app/project/y1sH6Zlg/noroutine)

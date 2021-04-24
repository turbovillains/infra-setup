elastic.md
===

# Keepalive settings

```
sysctl -w net.ipv4.tcp_keepalive_intvl=60
sysctl -w net.ipv4.tcp_keepalive_probes=20
sysctl -w net.ipv4.tcp_keepalive_time=600
```

# Delete all indices
curl -X DELETE http://bo01-vm-es01.node.bo01.noroutine.me:9201/_all


curl -k -s -X GET -u elastic:123234345 'https://10.0.22.80:9200/_cat/nodes?v&h=ip,id,name' |\
      sed 's/\(10.0.22.61\)/lab02-vm-nomad01 \1/' |\
      sed 's/\(10.0.22.62\)/lab02-vm-nomad02 \1/' |\
      sed 's/\(10.0.22.63\)/lab02-vm-nomad03 \1/' |\
      sed 's/\(10.0.22.64\)/lab02-vm-nomad04 \1/' |\
      sed 's/\(10.0.22.65\)/lab02-vm-nomad05 \1/' |\
      sed 's/\(10.0.22.66\)/lab02-vm-nomad06 \1/' |\
      sed 's/\(10.0.22.67\)/lab02-vm-nomad07 \1/' |\
      sed 's/\(10.0.22.68\)/lab02-vm-nomad08 \1/' |\
      sed 's/\(10.0.22.69\)/lab02-vm-nomad09 \1/' |\
      sed 's/\(10.0.22.70\)/lab02-vm-nomad10 \1/' |\
      sed 's/\(10.0.22.71\)/lab02-vm-nomad11 \1/' |\
      sed 's/\(10.0.22.72\)/lab02-vm-nomad12 \1/' |\
      sed 's/\(10.0.22.73\)/lab02-vm-nomad13 \1/' |\
      sed 's/\(10.0.22.74\)/lab02-vm-nomad14 \1/' |\
      sed 's/\(10.0.22.75\)/lab02-vm-nomad15 \1/' |\
      sed 's/\(10.0.22.76\)/lab02-vm-nomad16 \1/' |\
      sed 's/\(10.0.22.77\)/lab02-vm-nomad17 \1/' |\
      sed 's/\(10.0.22.78\)/lab02-vm-nomad18 \1/' |\
      sed 's/\(10.0.22.79\)/lab02-vm-nomad19 \1/' |\
      sed 's/\(10.0.22.80\)/lab02-vm-nomad20 \1/' |\
      sed 's/\(10.0.22.81\)/lab02-vm-nomad21 \1/' | sort


curl -k -s -X GET -u elasticsearch_admin:vJmULmAMOKmx https://infra-dsp-production-elasticsearch.service.dsp.allianz:1704/_cluster/recovery
curl -k -s -X GET -u elasticsearch_admin:vJmULmAMOKmx https://infra-dsp-production-elasticsearch.service.dsp.allianz:1704/_cluster/allocation/explain 

curl -k -s -X GET -u elasticsearch_admin:vJmULmAMOKmx https://infra-dsp-production-elasticsearch.service.dsp.allianz:1704/_cluster/health

curl -k -s -X PUT -u elasticsearch_admin:vJmULmAMOKmx -H'Content-Type: application/json' https://infra-dsp-production-elasticsearch.service.dsp.allianz:1704/_cluster/settings -d '{
 "transient": {
  "logger.org.elasticsearch.discovery": "DEBUG",
  "logger.org.elasticsearch.indices.recovery": "DEBUG",
  "logger.org.elasticsearch.transport": "DEBUG",
  "logger.org.elasticsearch.cluster.health": "DEBUG"
  "cluster.routing.allocation.disk.watermark.low": 95
 }
}'

curl -k -s -X PUT -H'Content-Type: application/json' http://bo01-vm-es01.node.bo01.noroutine.me:9201/_cluster/settings -d '{
 "transient": {
  "cluster.routing.allocation.disk.threshold_enabled": true
 }
}'


https://dsp-gafsp-elastic.service.dsp.allianz:9200/

curl -k -s -X GET -u elasticsearch_admin:vJmULmAMOKmx https://infra-dsp-production-elasticsearch.service.dsp.allianz:9300/_cat/nodes

curl -k -s -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cat/nodes |\
      sed 's/\(10.250.20.7\)/dsp-01 \1/' |\
      sed 's/\(10.250.20.8\)/dsp-02 \1/' |\
      sed 's/\(10.250.20.9\)/dsp-03 \1/' |\
      sed 's/\(10.250.20.10\)/dsp-04 \1/' |\
      sed 's/\(10.250.20.11\)/dsp-05 \1/' |\
      sed 's/\(10.250.20.12\)/dsp-06 \1/' | sort
curl -k -s -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cluster/health | jq .
curl -k -s -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cat/shards?h=index,shard,prirep,state,unassigned.reason | grep UNAS

for node in $(nomad node status | sed -n 's/.* \(gafsp-[0-9]*\).*/\1/p')
do
    
    ssh -oStrictHostKeyChecking=no -oGlobalKnownHostsFile=/dev/null $node.node.dsp.allianz sudo ls /usr/share/gafs-elastic/elasticsearch/data/nodes/*/indices/vvN6NRLWQfGdZLv3Hbbdmg/2/index 2>&1> /dev/null&& echo -en "\n$node\n"
done

curl -k -s -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cat/indices
curl -k -s -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cat/shards?h=index,shard,prirep,state,node,unassigned.reason
curl -k -s -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cat/nodes
curl -k -s -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cat/shards
curl -k -s -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cluster/allocation/explain  | jq .

curl -k -s -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_tasks
curl -k -s -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cluster/settings
curl -k -s -X PUT -u elastic:123234345 -H'Content-Type: application/json' https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cluster/settings -d '{
 "transient": {
  "cluster.routing.allocation.node_concurrent_recoveries": 2
 }
}'

explain specific shard

curl -k -s -H'Content-Type: application/json' -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cluster/allocation/explain -d '{ "index": "test-index-3", "primary": true, "shard": 72 }'  | jq . 



curl -k -s -XPOST -H'Content-Type: application/json' -u elastic:123234345 'https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cluster/reroute?retry_failed=true'

curl -k -s -XPOST -H'Content-Type: application/json' -u elastic:123234345 'https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cluster/reroute?pretty' -d '{
    "commands" : [
        {
          "allocate_replica": {
            "index": "resolver-atclaim-19-5-2-rc1-f-telephone",
            "shard": 0,
            "node": "gafs-elastic-2"
          }
        }
    ]
}'


curl -k -s -XPOST -H'Content-Type: application/json' -u elastic:123234345 'https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cluster/reroute?pretty' -d '{
    "commands" : [ {
        "allocate_stale_primary" :
            {
              "index" : "resolver-depolicy-0-2-email", "shard" : 3,
              "node" : "gafs-elastic-11",
              "accept_data_loss" : true
            }
        }
    ]
}'


 curl -k -s -H'Content-Type: application/json' -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cluster/allocation/explain -d '{ "index": "resolver-ptpolicy-19-5-2-eos1-f-individual", "primary": true, "shard": 0 }'  | jq '.node_allocation_decisions[] | select(.store.in_sync == false) | .node_name'


resolver-testpolicy-0-2-telephone


curl -k -s -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cat/indices/resolver-testpolicy-0-2-telephone

nodes

10.249.24.29 19 98  5 0.25 0.36 0.25 mdi - gafs-elastic-10          gafsp-18 x
10.249.24.17 67 98  4 0.08 0.09 0.08 mdi - gafs-elastic-4           gafsp-06
10.249.24.16 29 98  2 0.00 0.05 0.07 mdi - gafs-elastic-3           gafsp-05
10.249.24.31 59 97  6 0.15 0.22 0.18 mdi - gafs-elastic-1           gafsp-20
10.249.24.26 65 98  6 0.04 0.14 0.18 mdi - gafs-elastic-11          gafsp-07 x
10.249.24.33 50 97  7 0.25 0.30 0.18 mdi - gafs-elastic-0           gafsp-22
10.249.24.32 51 98  2 0.27 0.34 0.22 mdi - gafs-elastic-7           gafsp-21
10.249.24.28 71 96  6 0.45 0.19 0.12 mdi - gafs-elastic-5           gafsp-17
10.249.24.18 36 97  6 0.22 0.24 0.23 mdi - gafs-elastic-6           gafsp-09 
10.249.24.27 25 96  1 0.14 0.10 0.09 mdi - gafs-elastic-9           gafsp-16 x
10.249.24.20 30 98 17 1.14 0.61 0.53 mdi * gafs-elastic-8           gafsp-08
10.249.24.30 69 97 18 0.49 0.65 0.69 mdi - gafs-elastic-2           gafsp-19


1 allocation should be made stable 


gafs-elastic-(node_name) gafsp-06

2 enough time to shutdown cluster to close shards correctly
  proper proecedure to shutdown 

shard 3 

gafsp-19
gafsp-17
gafsp-09

shard 4

gafsp-05 10.249.24.16
gafsp-07 10.249.24.26
gafsp-20 10.249.24.31


shard 1

gafsp-22
gafsp-18
gafsp-16

curl -k -s -X GET -u elastic:123234345 https://dsp-gafsp-elastic.service.dsp.allianz:9200/_cat/shards/resolver-chclaim-0-2-individual

Vl8o7sH4QmOK2qlwdpxgBQ


        "allocation_id": "UzfZ-MVMS0avjH_GkDFSvg"
        "allocation_id": "GVDo3ukoQwyxu9vVOEVEmg"
        "allocation_id": "S1k9wYrvQpGIqDviv_lZHA"


resolver-chclaim-0-2-individual 4 p UNASSIGNED                            
resolver-chclaim-0-2-individual 4 r UNASSIGNED                            
resolver-chclaim-0-2-individual 4 r UNASSIGNED                            
resolver-chclaim-0-2-individual 1 p UNASSIGNED                            
resolver-chclaim-0-2-individual 1 r UNASSIGNED                            
resolver-chclaim-0-2-individual 1 r UNASSIGNED                            
resolver-chclaim-0-2-individual 3 p UNASSIGNED                            
resolver-chclaim-0-2-individual 3 r UNASSIGNED                            
resolver-chclaim-0-2-individual 3 r UNASSIGNED                            
resolver-chclaim-0-2-individual 2 r STARTED    1604335 5.8gb 10.249.24.28 gafs-elastic-5
resolver-chclaim-0-2-individual 2 r STARTED    1604335 5.7gb 10.249.24.17 gafs-elastic-4
resolver-chclaim-0-2-individual 2 p STARTED    1594070 4.5gb 10.249.24.20 gafs-elastic-8
resolver-chclaim-0-2-individual 0 r STARTED    1603052 5.6gb 10.249.24.29 gafs-elastic-10
resolver-chclaim-0-2-individual 0 r STARTED    1603052   5gb 10.249.24.26 gafs-elastic-11
resolver-chclaim-0-2-individual 0 p STARTED    1592937 4.5gb 10.249.24.20 gafs-elastic-8

# Initialize

curl -X GET http://localhost:7201/api/v1/services/m3coordinator/placement

curl -X GET http://localhost:7201/api/v1/services/m3db/namespace

http://hostname:7201/api/v1/
curl -X POST http://localhost:7201/api/v1/database/namespace/create -d '{
  "namespaceName": "metrics",
  "retentionTime": "168h"
}'

curl -X POST http://localhost:7201/api/v1/services/m3db/namespace/ready -d '{
  "name": "metrics"
}' | jq 

curl -X DELETE http://localhost:7201/api/v1/services/m3db/namespace/default_unaggregated


# View

Namespace
 curl -s -X GET http://lab01-vm-m3c01.node.lab01.noroutine.me:7201/api/v1/namespace | jq .
 curl -s -X GET http://m3c.service.bo01.noroutine.me:7201/api/v1/namespace | jq .

Placement 
 curl -s -X GET http://lab01-vm-m3c01.node.lab01.noroutine.me:7201/api/v1/placement | jq .

 curl -s -X GET http://m3c.service.bo01.noroutine.me:7201/api/v1/placement | jq .

## Local DB
curl -X POST http://infra-m3coordinator.service.lab03.noroutine.me:7201/api/v1/database/namespace/create -d '{
  "namespaceName": "metrics2",
  "type": "cluster",
  "retentionTime": "24h"
}'

curl -X POST http://infra-m3dbnode-0.service.lab03.noroutine.me:7201/api/v1/database/create -d '{
  "type": "local",
  "namespaceName": "metrics",
  "retentionTime": "48h"
}'

## Delete placement
curl -X DELETE http://lab01-vm-m3c01.node.lab01.noroutine.me:7201/api/v1/placement

## Delete namespace
curl -X DELETE http://lab01-vm-m3c01.node.lab01.noroutine.me:7201/api/v1/namespace/metrics

## Clustered DB
curl -X POST http://lab01-vm-m3c01.node.lab01.noroutine.me:7201/api/v1/database/create -d '{
  "type": "cluster",
  "namespaceName": "metrics",
  "retentionTime": "168h",
  "numShards": "1024",
  "replicationFactor": "3",
  "hosts": [
        {
            "id": "lab01-vm-m3db01",
            "isolationGroup": "m3db01",
            "zone": "embedded",
            "weight": 100,
            "address": "lab01-vm-m3db01.node.lab01.noroutine.me",
            "port": 9000
        },
        {
            "id": "lab01-vm-m3db02",
            "isolationGroup": "m3db02",
            "zone": "embedded",
            "weight": 100,
            "address": "lab01-vm-m3db02.node.lab01.noroutine.me",
            "port": 9000
        },
        {
            "id": "lab01-vm-m3db03",
            "isolationGroup": "m3db03",
            "zone": "embedded",
            "weight": 100,
            "address": "lab01-vm-m3db03.node.lab01.noroutine.me",
            "port": 9000
        }
    ]
}'

curl -X POST http://m3c.service.bo01.noroutine.me:7201/api/v1/database/create -d '{
  "type": "cluster",
  "namespaceName": "metrics",
  "retentionTime": "336h",
  "numShards": "1024",
  "replicationFactor": "3",
  "hosts": [
        {
            "id": "bo01-vm-m3db01",
            "isolationGroup": "group01",
            "zone": "embedded",
            "weight": 100,
            "address": "bo01-vm-m3db01.node.bo01.noroutine.me",
            "port": 9000
        },
        {
            "id": "bo01-vm-m3db02",
            "isolationGroup": "group02",
            "zone": "embedded",
            "weight": 100,
            "address": "bo01-vm-m3db02.node.bo01.noroutine.me",
            "port": 9000
        },
        {
            "id": "bo01-vm-m3db03",
            "isolationGroup": "group03",
            "zone": "embedded",
            "weight": 100,
            "address": "bo01-vm-m3db03.node.bo01.noroutine.me",
            "port": 9000
        }
    ]
}'

curl -s http://infra-traefik.service.lab03.noroutine.me/infra-m3coordinator-0-metrics/metrics

curl --verbose -s -X DELETE http://infra-m3coordinator.service.lab03.noroutine.me:7201/api/v1/services/m3db/placement/infra-m3db-0

curl --verbose -X POST http://infra-m3coordinator.service.lab03.noroutine.me:7201/api/v1/services/m3db/placement -d '{
  "instances": [
    {
      "id": "infra-m3db-0-x",
      "isolationGroup": "group-0",
      "zone": "embedded",
      "weight": 100,
      "endpoint": "10.0.23.65:9000",
      "hostname": "10.0.23.65",
      "port": 9000
    }
  ]
}'

curl -s -X POST http://infra-m3coordinator.service.lab03.noroutine.me:7201//api/v1/services/m3db/placement -d '{
  "instances": [
    {
      "id": "infra-m3db-1-x",
      "isolationGroup": "group-1",
      "zone": "embedded",
      "weight": 100,
      "endpoint": "10.0.23.69:9000"
      "hostname": "10.0.23.69",
      "port": 9000
    }
  ]
}'

curl -s -x POST http://infra-m3coordinator.service.lab03.noroutine.me:7201//api/v1/services/m3db/placement -d '{
  "instances": [
    {
      "id": "infra-m3db-2-x",
      "isolationGroup": "group-2",
      "zone": "embedded",
      "weight": 100,
      "endpoint": "10.0.23.64:9000"
      "hostname": "10.0.23.64",
      "port": 9000
    }
  ]
}'

curl -sS -X POST http://10.0.23.64:9003/writetagged -d '{
  "namespace": "metrics",
  "id": "foo",
  "tags": [
    {
      "name": "city",
      "value": "new_york"
    },
    {
      "name": "endpoint",
      "value": "/request"
    }
  ],
  "datapoint": {
    "timestamp": '"$(date "+%s")"',
    "value": 42.123456789
  }
}'

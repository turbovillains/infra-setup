from .. import Environment

from grit import *
from .panels import *

environment: Environment = Environment.resolve()

if environment.name =="dev":
    stack = Stack(
        row8(oplogLag),
        row6(primaryServers),
        row8(healthyMembers, healthyMembers),
        row8(primaryServers, secondaryServers, availableConnections),
        row8(primaryServers, secondaryServers, availableConnections, availableConnections),
    )
else:
    stack = Stack(
        row8(oplogLag, availableConnections),
        row8(primaryServers, secondaryServers, numberOfMembers, healthyMembers),
    )

GritDash(
    uid="mongodb-alerts-grafanalib",
    title=f"MongoDB - Alerts ({environment.var1}) | {environment.name.upper()}",
    description="MongoDB Prometheus Exporter Dashboard. \nWorks well with https://github.com/dcu/mongodb_exporter\n\nIf you have the node_exporter running on the mongo instance, you will also get some useful alert panels related to disk io and cpu.\n\nThis is an updated version from https://grafana.com/grafana/dashboards/2583. \n\nApplicable to Mongo 4.28.\n\nTested with https://bitnami.com/stack/mongodb/helm",
    tags=[
        'prometheus'
    ],
    timezone="browser",
    dataSource="Prometheus",
    stack=stack
)

Folder(title="MongoDB")
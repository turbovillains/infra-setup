from .. import Environment

from grit import *
from .panels import *

environment: Environment = Environment.resolve()

GritDash(
    uid="mongodb-alerts",
    title=f"MongoDB - Example | {environment.name.upper()}",
    description="MongoDB Prometheus Exporter Dashboard",
    tags=[
        'prometheus'
    ],
    timezone="browser",
    dataSource="Prometheus",
    stack=Stack(
        row8(oplogLag),
        row6(primaryServers),
        row8(healthyMembers, healthyMembers),
        row8(primaryServers, secondaryServers, availableConnections),
    )
)

Folder(title="MongoDB")

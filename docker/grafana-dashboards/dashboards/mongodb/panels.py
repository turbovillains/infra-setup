"""
Mongodb Panels
"""

from grafanalib.core import (
    Graph, Legend, XAxis,
    Target,
    OPS_FORMAT
)

oplogLag = Graph(
    title="Oplog Lag",
    lineWidth=2,
    targets=[
        Target(
            expr="rate(mongodb_mongod_replset_oplog_head_timestamp[5m])",
            legendFormat='{{ instance }}'
        )
    ],
)

numberOfMembers = Graph(
    title="Number of Members",
    lineWidth=2,
    bars=True,
    legend=Legend(alignAsTable=True),
    xAxis=XAxis(show=False, mode="series", values=["current"]),
    targets=[
        Target(
            expr="mongodb_mongod_replset_number_of_members",
            legendFormat='# members - {{pod}}'
        )
    ],
)

healthyMembers = Graph(
    title="Healthy Members",
    lineWidth=2,
    bars=True,
    legend=Legend(alignAsTable=True),
    xAxis=XAxis(show=False, mode="series", values=["current"]),
    targets=[
        Target(
            expr="sum(mongodb_mongod_replset_member_health) by (pod)",
            legendFormat='healthy members - {{pod}}'
        )
    ],
)

primaryServers = Graph(
    title="Primary Servers",
    lineWidth=2,
    bars=True,
    legend=Legend(alignAsTable=True),
    xAxis=XAxis(show=False, mode="series", values=["current"]),
    targets=[
        Target(
            expr='min(mongodb_mongod_replset_member_state{state="PRIMARY"}) by (name)',
            legendFormat='{{name}}'
        )
    ],
)

secondaryServers = Graph(
    title="Secondary Servers",
    lineWidth=2,
    bars=True,
    legend=Legend(alignAsTable=True),
    xAxis=XAxis(show=False, mode="series", values=["current"]),
    targets=[
        Target(
            expr='min(mongodb_mongod_replset_member_state{state="SECONDARY"}) by (name)',
            legendFormat='{{name}}'
        )
    ],
)

availableConnections = Graph(
    title="Available Connections",
    lineWidth=2,
    legend=Legend(alignAsTable=True),
    targets=[
        Target(
            expr='min(mongodb_connections{state="available"}) by (state, pod)',
            legendFormat='{{state}}-{{pod}}'
        )
    ],
)

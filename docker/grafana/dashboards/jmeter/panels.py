"""
Mongodb Panels
"""

from grafanalib.core import (
    Dashboard, Panel, Graph, Legend, XAxis, TimeSeries, GaugePanel,
    Target, GridPos,
    OPS_FORMAT
)

someOtherPanel = somePanel = Graph(
    title="Oplog Lag",
    lineWidth=2,
    targets=[
        Target(
            expr="rate(mongodb_mongod_replset_oplog_head_timestamp[5m])",
            legendFormat='{{ instance }}'
        )
    ],
)

from grit import *
from .panels import *

GritDash(
    uid="jmeter-grafanalib",
    version=8,
    title="jmeter (grafanalib)",
    description="Your description",
    tags=[
        'prometheus'
    ],
    timezone="browser",
    dataSource="Prometheus",
    stack=Stack(
        row8(somePanel)
    )
)

GritDash(
    uid="jmeter-grafanalib-2",
    version=8,
    title="jmeter 2",
    description="Your description",
    tags=[
        'prometheus'
    ],
    timezone="browser",
    dataSource="Prometheus",
    stack=Stack(
        row6(someOtherPanel, someOtherPanel)
    )
)

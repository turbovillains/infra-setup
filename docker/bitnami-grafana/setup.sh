#!/bin/bash -eux

# Install well-known plugins
grafana_plugin_list=(
    # Default bitnami plugins
    "grafana-clock-panel"
    "grafana-piechart-panel"
    "michaeldmoore-annunciator-panel"
    "briangann-gauge-panel"
    "briangann-datatable-panel"
    "jdbranham-diagram-panel"
    "natel-discrete-panel"
    "digiapulssi-organisations-panel"
    "vonage-status-panel"
    "neocat-cal-heatmap-panel"
    "agenty-flowcharting-panel"
    "larona-epict-panel"
    "pierosavi-imageit-panel"
    "michaeldmoore-multistat-panel"
    "grafana-polystat-panel"
    "scadavis-synoptic-panel"
    "marcuscalidus-svg-panel"
    "snuids-trafficlights-panel"

    # Extra plugins
    "abhisant-druid-datasource"
    "grafana-worldmap-panel"
    "savantly-heatmap-panel"
    "mtanda-histogram-panel"
    "zuburqan-parity-report-panel"
    "petrslavotinek-carpetplot-panel"
    "ryantxu-ajax-panel"
    "ryantxu-annolist-panel"
    "snuids-radar-panel"
    "goshposh-metaqueries-datasource"
    "xginn8-pagerduty-datasource"
    "flant-statusmap-panel"
    "pixie-pixie-datasource"
)

for plugin in "${grafana_plugin_list[@]}"; do
    echo "Installing ${plugin} plugin"
    grafana cli --pluginsDir /opt/bitnami/grafana/default-plugins plugins install "$plugin"
done





# End of file

#!/bin/bash -eux

grafana-cli plugins install abhisant-druid-datasource
grafana-cli plugins install grafana-worldmap-panel
grafana-cli plugins install grafana-piechart-panel
grafana-cli plugins install briangann-gauge-panel
grafana-cli plugins install savantly-heatmap-panel
grafana-cli plugins install mtanda-histogram-panel
grafana-cli plugins install michaeldmoore-annunciator-panel
grafana-cli plugins install zuburqan-parity-report-panel
grafana-cli plugins install petrslavotinek-carpetplot-panel
grafana-cli plugins install ryantxu-ajax-panel
grafana-cli plugins install ryantxu-annolist-panel
grafana-cli plugins install snuids-radar-panel
grafana-cli plugins install snuids-trafficlights-panel
grafana-cli plugins install jdbranham-diagram-panel
# grafana-cli plugins install devopsprodigy-kubegraf-app
grafana-cli plugins install michaeldmoore-multistat-panel
grafana-cli plugins install scadavis-synoptic-panel
grafana-cli plugins install goshposh-metaqueries-datasource
grafana-cli plugins install xginn8-pagerduty-datasource
grafana-cli plugins install flant-statusmap-panel
provider "nomad" {}

variable "deploy_environment" {}

variable "nomad_datacenter" {}

variable "nomad_namespace" {}

variable "vault_token" {}

variable "gitlab_metrics_token" {}

variable "docker_hub" {}

variable "service_domain" {}

variable "apps_domain" {}

variable "version_ref" {}

variable "http_proxy" {
  default = ""
}

variable "m3c_url" {}

variable "tls_ca_cert_file" {}
variable "tls_client_cert_file" {}
variable "tls_client_key_file" {}

variable "slack_url" {}
variable "slack_alert_channel" {}
variable "slack_warning_channel" {}

variable "grafana_root_url" {}

variable "grafana_ldap_host" {}
variable "grafana_ldap_port" {}
variable "grafana_ldap_use_ssl" { type = bool }
variable "grafana_ldap_start_tls" { type = bool }
variable "grafana_ldap_bind_dn" {}
variable "grafana_ldap_bind_pw" {
  default = ""
}

variable "grafana_ldap_base_dn" {}
variable "grafana_ldap_search_filter" {}
variable "grafana_ldap_admin_group_dn" {}

variable "elasticsearch_hosts" {
  type = list
}

resource "nomad_job" "prometheus" {
  for_each = local.namespaces[var.deploy_environment]
  jobspec = templatefile("../../jobs/prometheus.hcl", {
    name           = "prometheus"
    datacenter     = var.nomad_datacenter
    namespace      = each.key
    cluster        = "lab01"
    resources      = local.resources[var.deploy_environment]["prometheus"]
    service_domain = var.service_domain
    apps_domain    = var.apps_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/prometheus:${var.version_ref}"
    config = {
      data        = file("../../config/${lookup(local.namespaces[var.deploy_environment][each.key], "prometheus_config", "oe-prometheus")}/prometheus.yml.tpl")
      constraints = <<EOC
EOC
      tls = {
        ca          = file(var.tls_ca_cert_file)
        client_cert = file(var.tls_client_cert_file)
        client_key  = file(var.tls_client_key_file)
      }
      consul = {
        datacenter = var.nomad_datacenter
      }
      vault = {
        token = var.vault_token
      }
      gitlab = {
        metrics_token = var.gitlab_metrics_token
      }
    }
  })
}

resource "nomad_job" "prometheus-root" {
  jobspec = templatefile("../../jobs/prometheus-root.hcl", {
    name           = "prometheus-root"
    datacenter     = var.nomad_datacenter
    namespace      = var.nomad_namespace
    resources      = local.resources[var.deploy_environment]["prometheus-root"]
    service_domain = var.service_domain
    apps_domain    = var.apps_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/prometheus:${var.version_ref}"
    config = {
      data  = file("../../config/infra-prometheus-root/${var.deploy_environment}/prometheus.yml.tpl")
      rules = file("../../config/infra-prometheus-root/${var.deploy_environment}/rules.yml")
      remote = {
        read  = "${var.m3c_url}/api/v1/prom/remote/read"
        write = "${var.m3c_url}/api/v1/prom/remote/write"
      }
      consul = {
        datacenter = var.nomad_datacenter
      }
    }
  })
}

resource "nomad_job" "alertmanager" {
  jobspec = templatefile("../../jobs/alertmanager.hcl", {
    name           = "alertmanager"
    datacenter     = var.nomad_datacenter
    namespace      = var.nomad_namespace
    resources      = local.resources[var.deploy_environment]["alertmanager"]
    service_domain = var.service_domain
    apps_domain    = var.apps_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/alertmanager:${var.version_ref}"
    template = {
      template1      = file("../../config/infra-alertmanager/${var.deploy_environment}/template1.tmpl")
      template-debug = file("../../config/infra-alertmanager/${var.deploy_environment}/template-debug.tmpl")
    }
    config = {
      data                  = file("../../config/infra-alertmanager/${var.deploy_environment}/alertmanager.yml.tpl")
      http_proxy            = var.http_proxy
      slack_url             = var.slack_url
      slack_alert_channel   = var.slack_alert_channel
      slack_warning_channel = var.slack_warning_channel
    }
  })
}

resource "nomad_job" "pushgateway" {
  jobspec = templatefile("../../jobs/pushgateway.hcl", {
    name           = "pushgateway"
    datacenter     = var.nomad_datacenter
    namespace      = var.nomad_namespace
    resources      = local.resources[var.deploy_environment]["pushgateway"]
    service_domain = var.service_domain
    apps_domain    = var.apps_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/pushgateway:${var.version_ref}"
  })
}

resource "nomad_job" "grafana" {
  jobspec = templatefile("../../jobs/grafana.hcl", {
    name           = "grafana"
    datacenter     = var.nomad_datacenter
    namespace      = var.nomad_namespace
    resources      = local.resources[var.deploy_environment]["grafana"]
    service_domain = var.service_domain
    apps_domain    = var.apps_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/grafana:${var.version_ref}"
    config = {
      ca       = file("/etc/ssl/certs/ca-certificates.crt")
      data     = file("../../config/infra-grafana/grafana.ini.tpl")
      root_url = var.grafana_root_url
      datasources = {
        "m3db"       = var.m3c_url
        "bo01-m3c"   = "http://bo01-m3coordinator.service.bo01.noroutine.me:7201"
        "lab01-m3c"  = "http://lab01-m3coordinator.service.lab01.noroutine.me:7201"
        "bo01-root"  = "http://bo01-prometheus-root.service.bo01.noroutine.me:9089"
        "lab01-root" = "http://lab01-prometheus-root.service.lab01.noroutine.me:9089"
        # "cortex"          = "http://infra-cortex.${var.service_domain}:9009/api/prom"
      }
      dashboards = {
        "overview" = file("../../config/infra-grafana/dashboards/overview.json"),
        "template" = file("../../config/infra-grafana/dashboards/template.json"),
        "storage"  = file("../../config/infra-grafana/dashboards/storage.json"),
        "consul"   = file("../../config/infra-grafana/dashboards/consul.json"),
        "m3"       = file("../../config/infra-grafana/dashboards/m3.json"),
        "network"  = file("../../config/infra-grafana/dashboards/network.json"),
        "ports"    = file("../../config/infra-grafana/dashboards/ports.json"),
      },
      ldap = {
        data           = file("../../config/infra-grafana/ldap.toml.tpl")
        host           = var.grafana_ldap_host
        port           = var.grafana_ldap_port
        use_ssl        = var.grafana_ldap_use_ssl
        start_tls      = var.grafana_ldap_start_tls
        bind_dn        = var.grafana_ldap_bind_dn
        bind_pw        = var.grafana_ldap_bind_pw
        base_dn        = var.grafana_ldap_base_dn
        search_filter  = var.grafana_ldap_search_filter
        admin_group_dn = var.grafana_ldap_admin_group_dn
      }
    }
  })
}

# resource "nomad_job" "etcd-m3" {
#   jobspec = templatefile("../../jobs/etcd.hcl", {
#     name       = "etcd-m3"
#     datacenter = var.nomad_datacenter
#     namespace  = "lab01"
#     image      = "${var.docker_hub}/coreos/etcd:v3.4.3"
#     # image = "${var.docker_hub}/tmp/delayed_etcd:v3.4.3-1"
#   })
# }

# resource "nomad_job" "etcd-gateway" {
#   jobspec = templatefile("../../jobs/etcd-gateway.hcl", {
#     name       = "etcd-m3-gateway"
#     datacenter = var.nomad_datacenter
#     namespace  = "lab01"
#     image      = "${var.docker_hub}/${local.docker_namespace}/etcd:v3.4.3"
#   })
# }

# resource "nomad_job" "m3dbnode" {
#   jobspec = templatefile("../../jobs/m3dbnode.hcl", {
#     name           = "m3dbnode"
#     datacenter     = var.nomad_datacenter
#     namespace      = "lab01"
#     resources      = local.resources[var.deploy_environment]["m3dbnode"]
#     service_domain = var.service_domain
#     image          = "${var.docker_hub}/${local.docker_namespace}/m3dbnode:${var.version_ref}"
#     config = {
#       data = file("../../config/infra-m3dbnode/m3dbnode.yml.tpl")
#     }
#   })
# }

resource "nomad_job" "m3coordinator" {
  jobspec = templatefile("../../jobs/m3coordinator.hcl", {
    name       = "m3coordinator"
    datacenter = var.nomad_datacenter
    namespace  = var.nomad_namespace
    resources  = local.resources[var.deploy_environment]["m3coordinator"]
    image      = "${var.docker_hub}/${local.docker_namespace}/m3coordinator:${var.version_ref}"
    # image      = "${var.docker_hub}/${local.docker_namespace}/m3coordinator:v0.14.2-noverify-1"
    config = {
      data = file("../../config/infra-m3coordinator/m3coordinator.yml")
      tls = {
        ca          = file(var.tls_ca_cert_file)
        client_cert = file(var.tls_client_cert_file)
        client_key  = file(var.tls_client_key_file)
      }
    }
  })
}

resource "nomad_job" "kibana" {
  jobspec = templatefile("../../jobs/kibana.hcl", {
    name       = "kibana"
    datacenter = var.nomad_datacenter
    namespace  = var.nomad_namespace
    resources  = local.resources[var.deploy_environment]["kibana"]
    image      = "${var.docker_hub}/${local.docker_namespace}/kibana:${var.version_ref}"
    config = {
      data                = file("../../config/infra-kibana/kibana.yml")
      elasticsearch_hosts = var.elasticsearch_hosts
      tls = {
        ca          = file(var.tls_ca_cert_file)
        client_cert = file(var.tls_client_cert_file)
        client_key  = file(var.tls_client_key_file)
      }
    }
  })
}

resource "nomad_job" "logstash" {
  jobspec = templatefile("../../jobs/logstash.hcl", {
    name       = "logstash"
    datacenter = var.nomad_datacenter
    namespace  = var.nomad_namespace
    resources  = local.resources[var.deploy_environment]["logstash"]
    image      = "${var.docker_hub}/${local.docker_namespace}/logstash:${var.version_ref}"
    config = {
      data = templatefile("../../config/infra-logstash/logstash.yml", {
        elasticsearch_hosts = var.elasticsearch_hosts
      })
      pipelines = {
        "beats-input"  = file("../../config/infra-logstash/pipeline/beats-input.conf"),
        "syslog-input" = file("../../config/infra-logstash/pipeline/syslog-input.conf"),
        "elasticsearch-output" = templatefile("../../config/infra-logstash/pipeline/elasticsearch-output.conf.tmpl", {
          elasticsearch_hosts = var.elasticsearch_hosts
        }),
      }
      tls = {
        ca          = file(var.tls_ca_cert_file)
        client_cert = file(var.tls_client_cert_file)
        client_key  = file(var.tls_client_key_file)
      }
    }
  })
}

# resource "nomad_job" "node-exporter" {
#   for_each = local.namespaces[var.deploy_environment]
#   jobspec = templatefile("../../jobs/node-exporter.hcl", {
#     name           = "node-exporter"
#     datacenter     = var.nomad_datacenter
#     namespace      = each.key
#     resources      = local.resources[var.deploy_environment]["node-exporter"]
#     service_domain = var.service_domain
#     image          = "${var.docker_hub}/${local.docker_namespace}/node-exporter:${var.version_ref}"
#   })
# }

resource "nomad_job" "cadvisor" {
  for_each = local.namespaces[var.deploy_environment]
  jobspec = templatefile("../../jobs/cadvisor.hcl", {
    name           = "cadvisor"
    datacenter     = var.nomad_datacenter
    namespace      = each.key
    resources      = local.resources[var.deploy_environment]["cadvisor"]
    service_domain = var.service_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/cadvisor:${var.version_ref}"
  })
}

resource "nomad_job" "ssl-exporter" {
  for_each = local.namespaces[var.deploy_environment]
  jobspec = templatefile("../../jobs/ssl-exporter.hcl", {
    name           = "ssl-exporter"
    datacenter     = var.nomad_datacenter
    namespace      = var.nomad_namespace
    resources      = local.resources[var.deploy_environment]["ssl-exporter"]
    service_domain = var.service_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/ssl-exporter:${var.version_ref}"
  })
}

resource "nomad_job" "prometheus-es-exporter" {
  jobspec = templatefile("../../jobs/prometheus-es-exporter.hcl", {
    name           = "prometheus-es-exporter"
    datacenter     = var.nomad_datacenter
    namespace      = var.nomad_namespace
    resources      = local.resources[var.deploy_environment]["prometheus-es-exporter"]
    service_domain = var.service_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/prometheus-es-exporter:${var.version_ref}"
  })
}

resource "nomad_job" "blackbox-exporter" {
  jobspec = templatefile("../../jobs/blackbox-exporter.hcl", {
    name           = "blackbox-exporter"
    datacenter     = var.nomad_datacenter
    namespace      = var.nomad_namespace
    resources      = local.resources[var.deploy_environment]["blackbox-exporter"]
    service_domain = var.service_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/blackbox-exporter:${var.version_ref}"
    config = {
      data = file("../../config/infra-blackbox-exporter/blackbox-exporter.yml")
      tls = {
        ca = file("/etc/ssl/certs/ca-certificates.crt")
      }
    }
  })
}

resource "nomad_job" "consul-exporter" {
  jobspec = templatefile("../../jobs/consul-exporter.hcl", {
    name           = "consul-exporter"
    datacenter     = var.nomad_datacenter
    namespace      = var.nomad_namespace
    resources      = local.resources[var.deploy_environment]["consul-exporter"]
    service_domain = var.service_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/consul-exporter:${var.version_ref}"
  })
}

resource "nomad_job" "ioping-exporter" {
  jobspec = templatefile("../../jobs/ioping-exporter.hcl", {
    name           = "ioping-exporter"
    datacenter     = var.nomad_datacenter
    namespace      = var.nomad_namespace
    resources      = local.resources[var.deploy_environment]["ioping-exporter"]
    service_domain = var.service_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/ioping-exporter:${var.version_ref}"
  })
}

resource "nomad_job" "ldap-exporter" {
  jobspec = templatefile("../../jobs/ldap-exporter.hcl", {
    name           = "ldap-exporter"
    datacenter     = var.nomad_datacenter
    namespace      = var.nomad_namespace
    resources      = local.resources[var.deploy_environment]["ldap-exporter"]
    service_domain = var.service_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/ldap-exporter:${var.version_ref}"
    config = {
      tls = {
        ca = file(var.tls_ca_cert_file)
      }
      ldap = {
        uri    = "ldaps://${var.grafana_ldap_host}"
        baseDN = var.grafana_ldap_base_dn
      }
    }
  })
}

resource "nomad_job" "snmp-exporter" {
  jobspec = templatefile("../../jobs/snmp-exporter.hcl", {
    name           = "snmp-exporter"
    datacenter     = var.nomad_datacenter
    namespace      = var.nomad_namespace
    resources      = local.resources[var.deploy_environment]["snmp-exporter"]
    service_domain = var.service_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/snmp-exporter:${var.version_ref}"
    config = {
      snmp = file("../../config/infra-snmp-exporter/snmp.yml")
    }
  })
}

# resource "nomad_job" "cortex" {
#   jobspec = templatefile("../../jobs/cortex.hcl", {
#     name           = "cortex"
#     datacenter     = var.nomad_datacenter
#     namespace      = "lab01"
#     resources      = local.resources[var.deploy_environment]["cortex"]
#     service_domain = var.service_domain
#     image          = "${var.docker_hub}/${local.docker_namespace}/cortex:${var.version_ref}"
#     config = {
#       template = file("../../config/infra-cortex/cortex.yml")
#     }
#   })
# }

resource "nomad_job" "rsyslog" {
  jobspec = templatefile("../../jobs/rsyslog.hcl", {
    name           = "rsyslog"
    datacenter     = var.nomad_datacenter
    namespace      = var.nomad_namespace
    resources      = local.resources[var.deploy_environment]["rsyslog"]
    service_domain = var.service_domain
    image          = "${var.docker_hub}/${local.docker_namespace}/rsyslog:${var.version_ref}"
    config = {
      omelasticsearch = templatefile("../../config/infra-rsyslog/omelasticsearch.conf", {
        elasticsearch_hosts = var.elasticsearch_hosts
        index_name_prefix   = "rsyslog"
      })
    }
  })
}


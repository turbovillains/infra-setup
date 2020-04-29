locals {
  docker_namespace = "infra"
  resources = {
    "bo01" = {
      "radius" = {
        cpu    = 100
        memory = 128
      }
    }
    "lab01" = {
      "radius" = {
        cpu    = 100
        memory = 128
      }
    }
  }
  namespaces = {
    bo01 = {
      bo01 = {
        description = "bo01 namespace"
      }
    }
    lab01 = {
      lab01 = {
        description = "lab01 namespace"
      }
    }
  }
}

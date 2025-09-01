variable "talos" {
  type = object({
    factory = object({
      url       = string
      platform  = string
      arch      = string
    })
    cluster = object({
      name                = optional(string)
      kubernetes_version  = string
      talos_version       = string
      api_server_endpoint = string
      extensions          = optional(list(string))
      networking          = object({
        cni             = string
        pod_subnets     = optional(list(string))
        service_subnets = optional(list(string))
        default_gateway = string
        dns_servers     = list(string)
        ntp_servers     = list(string)
      })
      monitoring          = object({
        kubernetes_metrics_server = optional(bool)
        containerd_metrics_server = optional(bool)
      })
      storage = optional(object({
        extra_kubelet_mounts = optional(list(object({
          destination = string
          source      = string
          type        = string
          options     = optional(list(string))
        })), [])
      }), {})  # default empty object
      compute             = object({
        control_plane = object({
          install_disk = string
          encryption_type = string
          nodes = map(object({}))
        })
        worker        = object({
          install_disk = string
          encryption_type = string
          nodes = map(object({}))
        })
      })
    })
  })
}

variable "environment" {
  type = string
}

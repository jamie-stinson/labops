environment = "production"

talos = {
  factory = {
    url      = "https://factory.talos.dev"
    platform = "metal"
    arch     = "amd64"
  }
  cluster = {
    kubernetes_version  = "v1.33.1"
    talos_version       = "v1.10.3"
    api_server_endpoint = "kubeapi.projectwhitebox.com"
    networking = {
      cni             = "flannel"
      pod_subnets     = ["10.244.0.0/16"]
      service_subnets = ["10.96.0.0/12"]
      default_gateway = "10.0.0.1"
      dns_servers     = ["10.0.0.19"]
      ntp_servers     = ["time.cloudflare.com"]
    }
    monitoring = {
      kubernetes_metrics_server = true
      containerd_metrics_server = true
    }
    compute = {
      control_plane = {
        install_disk    = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0" # need to get disk
        encryption_type = "local"
        resources = {
          system = {
            cpu     = "250m"
            memory  = "512Mi"
            storage = "4Gi"
          }
          kube = {
            cpu     = "1000m"
            memory  = "2Gi"
            storage = "10Gi"
          }
        }
        nodes = {
          "10.10.0.10" = {}
          "10.10.0.11" = {}
          "10.10.0.12" = {}
        }
      }
      worker = {
        install_disk    = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_drive-scsi0"
        encryption_type = "local"
        resources = {
          system = {
            cpu     = "250m"
            memory  = "512Mi"
            storage = "4Gi"
          }
          kube = {
            cpu     = "1000m"
            memory  = "2Gi"
            storage = "10Gi"
          }
        }
        nodes           = {
          "10.0.0.15" = {}
        }
      }
    }
  }
}

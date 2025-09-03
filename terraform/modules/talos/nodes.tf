locals {
  node_hostnames = { for key, value in random_string.this : key => value.result }
}

data "talos_machine_configuration" "this" {
  for_each = {
    for ip, node in merge(
      var.talos.cluster.compute.control_plane.nodes,
      var.talos.cluster.compute.worker.nodes
    ) : ip => node
  }

  cluster_name       = coalesce(var.talos.cluster.name, var.environment)
  cluster_endpoint   = "https://${var.talos.cluster.api_server_endpoint}:6443"
  machine_type       = contains(keys(var.talos.cluster.compute.control_plane.nodes), each.key) ? "controlplane" : "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.talos.cluster.kubernetes_version
  talos_version      = var.talos.cluster.talos_version
}

resource "talos_machine_configuration_apply" "this" {
  for_each = {
    for ip, node in merge(
      var.talos.cluster.compute.control_plane.nodes,
      var.talos.cluster.compute.worker.nodes
    ) : ip => node
  }

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration
  node                        = each.key

  on_destroy = {
    graceful = true
    reboot   = false
    reset    = true
  }

  config_patches = flatten([
    [
    # Control Plane & Worker Template
      templatefile("${path.module}/templates/global.yaml.tmpl", {
        hostname = format(
          "%s-%s",
          contains(keys(var.talos.cluster.compute.control_plane.nodes), each.key) ? "control-plane" : "worker",
          local.node_hostnames[each.key]
        )
        install_disk              = (contains(keys(var.talos.cluster.compute.control_plane.nodes), each.key) ? var.talos.cluster.compute.control_plane.install_disk : var.talos.cluster.compute.worker.install_disk)
        encryption_type           = (contains(keys(var.talos.cluster.compute.control_plane.nodes), each.key) ? var.talos.cluster.compute.control_plane.encryption_type : var.talos.cluster.compute.worker.encryption_type)
        api_server_endpoint       = var.talos.cluster.api_server_endpoint
        extensions                = var.talos.cluster.extensions
        dns_servers               = var.talos.cluster.networking.dns_servers
        ntp_servers               = var.talos.cluster.networking.ntp_servers
        containerd_metrics_server = var.talos.cluster.monitoring.containerd_metrics_server
        kubernetes_metrics_server = var.talos.cluster.monitoring.kubernetes_metrics_server
        extra_mounts              = var.talos.cluster.storage.extra_kubelet_mounts
        talos_factory_image_url   = data.talos_image_factory_urls.this.urls.installer
      })
    ],
    contains(keys(var.talos.cluster.compute.worker.nodes), each.key) ? [
      templatefile("${path.module}/templates/worker.yaml.tmpl", {
      }),
    ] : [],
    # Control Plane Template
    contains(keys(var.talos.cluster.compute.control_plane.nodes), each.key) ? [
      templatefile("${path.module}/templates/controlPlane.yaml.tmpl", {
        api_server_endpoint       = var.talos.cluster.api_server_endpoint
        cni                       = var.talos.cluster.networking.cni
        pod_subnets               = var.talos.cluster.networking.pod_subnets
        service_subnets           = var.talos.cluster.networking.service_subnets
      }),
    # Disable Pod Security Admission
      templatefile("${path.module}/templates/podSecurityConfiguration.yaml.tmpl", {})
    ] : []
  ])
}

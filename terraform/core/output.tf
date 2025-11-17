output "talosconfig" {
  value     = module.talos.talosconfig
  sensitive = true
}

output "kubeconfig" {
  value     = module.talos.kubeconfig
  sensitive = true
}

#tofu output -raw kubeconfig > ~/.kube/config
#tofu output -raw talosconfig > ~/.talos/config

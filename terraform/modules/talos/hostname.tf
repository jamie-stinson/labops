resource "random_string" "this" {
  for_each = {
    for ip, node in merge(
      var.talos.cluster.compute.control_plane.nodes,
      var.talos.cluster.compute.worker.nodes
    ) : ip => node
  }

  length   = 8
  lower    = true
  numeric  = true
  upper    = true
  special  = false
}

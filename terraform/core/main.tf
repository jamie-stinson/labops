module "talos" {
  source      = "/Users/jamiestinson/Documents/GitHub/jamie-stinson/labops/terraform/modules/talos"
  talos       = var.talos
  environment = var.environment
}

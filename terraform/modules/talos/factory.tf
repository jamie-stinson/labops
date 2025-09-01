data "talos_image_factory_extensions_versions" "this" {
  talos_version = "${var.talos.cluster.talos_version}"
  filters = {
    names = var.talos.cluster.extensions
  }
}

resource "talos_image_factory_schematic" "this" {
  schematic = yamlencode(
    {
      customization = length(coalesce(var.talos.cluster.extensions, [])) > 0 ? {
        systemExtensions = {
          officialExtensions = data.talos_image_factory_extensions_versions.this.extensions_info[*].name
        }
      } : {}
    }
  )
}

data "talos_image_factory_urls" "this" {
  schematic_id  = talos_image_factory_schematic.this.id
  talos_version = "${var.talos.cluster.talos_version}"
  platform      = "${var.talos.factory.platform}"
  architecture  = "${var.talos.factory.arch}"
}

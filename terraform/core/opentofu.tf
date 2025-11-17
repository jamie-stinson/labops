terraform {
  required_version = "~> 1"

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "OpenJamLab"
    workspaces {
      name = "tofu-production"
    }
  }

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
}

provider "talos" {}
provider "random" {}

terraform {
  required_version = ">= 1.6"
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.70.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = ">= 1.0.0"
    }
  }
}

data "sops_file" "secrets" {
  source_file = "secrets.sops.yml"
}

provider "proxmox" {
  endpoint  = data.sops_file.secrets.data["proxmox_endpoint"]
  api_token = data.sops_file.secrets.data["proxmox_api_token"]
  insecure  = true # Proxmox uses a self-signed cert
}

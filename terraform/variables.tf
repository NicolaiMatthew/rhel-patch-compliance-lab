variable "node_name" {
  default = "host2"
}

variable "template_id" {
  default = 9100 # rhel9-template
}

variable "gateway" {
  default = "192.168.68.1"
}

variable "domain" {
  default = "lab.internal"
}

variable "dns_servers" {
  # dns01 first; router as fallback until BIND is up
  default = ["192.168.68.20", "192.168.68.1"]
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_ed25519.pub"
}

variable "lxc_template" {
  default = "local:vztmpl/rockylinux-9-default_20240912_amd64.tar.xz"
}

locals {
  ssh_key = trimspace(file(pathexpand(var.ssh_public_key_path)))

  vms = {
    katello     = { id = 221, template = 9100, ip = "192.168.68.21", cores = 4, memory = 16384, disk = 40, pulp_disk = 60 }
    rhel-dev01  = { id = 231, template = 9101, ip = "192.168.68.31", cores = 2, memory = 1536, disk = 20, pulp_disk = 0 }
    rhel-test01 = { id = 232, template = 9101, ip = "192.168.68.32", cores = 2, memory = 1536, disk = 20, pulp_disk = 0 }
    rhel-prod01 = { id = 233, template = 9101, ip = "192.168.68.33", cores = 2, memory = 1536, disk = 20, pulp_disk = 0 }
  }
}

resource "proxmox_virtual_environment_vm" "rhel" {
  for_each  = local.vms
  name      = each.key
  vm_id     = each.value.id
  node_name = var.node_name
  tags      = ["patchlab", "terraform"]
  on_boot   = true

  clone {
    vm_id = each.value.template
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = each.value.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = each.value.memory
  }

  # OS disk (resized from the template's 10G)
  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = each.value.disk
    iothread     = true
    discard      = "on"
  }

  # Second disk for /var/lib/pulp, only on katello
  dynamic "disk" {
    for_each = each.value.pulp_disk > 0 ? [1] : []
    content {
      datastore_id = "local-lvm"
      interface    = "scsi1"
      size         = each.value.pulp_disk
      file_format  = "raw"
      iothread     = true
      discard      = "on"
    }
  }

  network_device {
    bridge = "vmbr0"
  }

  operating_system {
    type = "l26"
  }

  serial_device {}

  vga {
    type = "serial0"
  }

  # cloud-init: first-boot identity
  initialization {
    datastore_id = "local-lvm"
    ip_config {
      ipv4 {
        address = "${each.value.ip}/22"
        gateway = var.gateway
      }
    }
    dns {
      domain  = var.domain
      servers = var.dns_servers
    }
    user_account {
      username = "ansible"
      keys     = [local.ssh_key]
    }
  }
}

resource "proxmox_virtual_environment_container" "dns01" {
  vm_id         = 220
  node_name     = var.node_name
  tags          = ["patchlab", "terraform"]
  unprivileged  = true
  start_on_boot = true

  initialization {
    hostname = "dns01"
    ip_config {
      ipv4 {
        address = "192.168.68.20/22"
        gateway = var.gateway
      }
    }
    dns {
      domain  = var.domain
      servers = ["192.168.68.1"]
    }
    user_account {
      keys = [local.ssh_key]
    }
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 512
    swap      = 512
  }

  disk {
    datastore_id = "local-lvm"
    size         = 8
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }

  operating_system {
    template_file_id = var.lxc_template
    type             = "centos"
  }

  features {
    nesting = true # needed for systemd in modern unprivileged containers
  }
}

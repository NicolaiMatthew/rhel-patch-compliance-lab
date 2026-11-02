output "vm_ips" {
  value = { for k, v in local.vms : k => v.ip }
}

output "dns01_ip" {
  value = "192.168.68.20"
}

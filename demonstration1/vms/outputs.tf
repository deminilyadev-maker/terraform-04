output "external_ip_address" {
  value = module.test-vm.external_ip_address
}

output "internal_ip_address" {
  value = module.test-vm.internal_ip_address
}

output "fqdn" {
  value = module.test-vm.fqdn
}

output "labels" {
  value = module.test-vm.labels
}
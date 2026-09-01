output "network_id" {
  value = yandex_vpc_network.root_network.id
}

output "subnet_id" {
  value = yandex_vpc_subnet.root_subnet.id
}
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "yandex_vpc_network" "root_network" {
  name = var.name
}

resource "yandex_vpc_subnet" "root_subnet" {
  name           = "${var.name}-${var.zone}"
  zone           = var.zone
  network_id     = yandex_vpc_network.root_network.id
  v4_cidr_blocks = var.v4_cidr_blocks
}
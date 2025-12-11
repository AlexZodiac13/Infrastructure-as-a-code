resource "yandex_vpc_network" "wp-network" {
  count = var.create_network ? 1 : 0
  name  = var.network_name
}

resource "yandex_vpc_subnet" "wp-subnet-a" {
  name = "wp-subnet-a"
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = var.create_network ? yandex_vpc_network.wp-network[0].id : var.network_id
}

resource "yandex_vpc_subnet" "wp-subnet-b" {
  name = "wp-subnet-b"
  v4_cidr_blocks = ["10.3.0.0/16"]
  zone           = "ru-central1-b"
  network_id     = var.create_network ? yandex_vpc_network.wp-network[0].id : var.network_id
}

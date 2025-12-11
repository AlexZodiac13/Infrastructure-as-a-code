locals {
  dbuser     = yandex_mdb_mysql_user.wp_db_user.name
  dbpassword = yandex_mdb_mysql_user.wp_db_user.password
  dbhosts    = yandex_mdb_mysql_cluster.wp_mysql.host.*.fqdn
  dbname     = yandex_mdb_mysql_database.wp_db.name
}

resource "yandex_mdb_mysql_cluster" "wp_mysql" {
  name        = "wp-mysql"
  folder_id   = var.yc_folder
  environment = "PRODUCTION"
  network_id  = var.create_network ? yandex_vpc_network.wp-network[0].id : var.network_id
  version     = "8.0"

  resources {
    resource_preset_id = "s2.micro"
    disk_type_id       = "network-ssd"
    disk_size          = 16
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.wp-subnet-a.id
    assign_public_ip = true
  }

  host {
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.wp-subnet-b.id
    assign_public_ip = true
  }
}

resource "yandex_mdb_mysql_database" "wp_db" {
  cluster_id = yandex_mdb_mysql_cluster.wp_mysql.id
  name       = "db"
}

resource "yandex_mdb_mysql_user" "wp_db_user" {
  cluster_id = yandex_mdb_mysql_cluster.wp_mysql.id
  name       = "user"
  password   = var.db_password
  authentication_plugin = "MYSQL_NATIVE_PASSWORD"

  permission {
    database_name = yandex_mdb_mysql_database.wp_db.name
    roles         = ["ALL"]
  }
}

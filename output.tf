output "load_balancer_public_ip" {
  description = "Public IP address of load balancer"
  value       = tolist(tolist(yandex_lb_network_load_balancer.wp_lb.listener).0.external_address_spec).0.address
}

output "db_user" {
  description = "DB user"
  value       = yandex_mdb_mysql_user.wp_db_user.name
}

output "db_password" {
  description = "DB password (for tests only)"
  value       = yandex_mdb_mysql_user.wp_db_user.password
  sensitive   = true
}

output "db_name" {
  description = "DB name"
  value       = yandex_mdb_mysql_database.wp_db.name
}

output "database_host_fqdn" {
  description = "DB hostname"
  value       = yandex_mdb_mysql_cluster.wp_mysql.host.*.fqdn
}

output "vm_linux_public_ip_address" {
  description = "Virtual machine IP"
  value       = yandex_compute_instance.wp-app-1.network_interface[0].nat_ip_address
}

output "vm_ssh_user" {
  description = "SSH user for VM"
  value       = var.user_name
}

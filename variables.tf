variable "yc_cloud_id" {
  type = string
  description = "Yandex Cloud ID"
}

variable "yc_folder_id" {
  type = string
  description = "Yandex Cloud folder"
}

variable "yc_token" {
  type = string
  description = "Yandex Cloud OAuth token"
}

variable "yc_zone" {
  type = string
  description = "Yandex Cloud default zone"
  default = "ru-central1-a"
}

variable "yc_dataproc_version" {
  type = string
  description = "Yandex Cloud DataProc version"
  default = "2.0"
}

variable "user_name" {
  type = string
  description = "Username for SSH access"
}

variable "public_key_path" {
  type = string
  description = "Path to SSH public key"
}

variable "private_key_path" {
  type = string
  description = "Path to SSH private key"
}

variable "db_password" {
  type = string
  description = "MySQL user password"
  default = "wordpress123!"
}

variable "yc_cloud" {
  type        = string
  description = "Yandex Cloud ID"
}

variable "yc_folder" {
  type        = string
  description = "Yandex Cloud folder"
}

variable "yc_token" {
  type        = string
  description = "Yandex Cloud OAuth token"
}

variable "yc_zone" {
  type        = string
  description = "Yandex Cloud default zone"
  default     = "ru-central1-a"
}

variable "yc_dataproc_version" {
  type        = string
  description = "Yandex Cloud Dataproc version"
  default     = "2.0"
}

variable "user_name" {
  type        = string
  description = "Username for SSH access"
  default     = "zodiac"
}

variable "public_key" {
  type        = string
  description = "SSH public key content"
}

variable "private_key" {
  type        = string
  description = "SSH private key content"
}

variable "db_password" {
  description = "MySQL user password"
  type        = string
  default     = "wordpress123!"
}

variable "create_network" {
  description = "Create a new VPC network (true) or reuse an existing network (false)"
  type        = bool
  default     = true
}

variable "network_id" {
  description = "If create_network is false, provide an existing VPC network id"
  type        = string
  default     = ""
}

variable "network_name" {
  description = "Optional name for the created network"
  type        = string
  default     = "wp-network"
}

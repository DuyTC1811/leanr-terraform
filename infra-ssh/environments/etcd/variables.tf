variable "ssh_user" {
  description = "SSH user to connect"
  type        = string
}

variable "ssh_host_etcd" {
  description = "IP of the etcd host"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to SSH private key"
  type        = string
}

variable "certificates_ca_path" {
  description = "Path to the CA certificate"
  type        = string
}

variable "certificates_etcd_path" {
  description = "Path to the etcd certificate"
  type        = string
}

variable "certificates_etcd_key_path" {
  description = "Path to the etcd private key"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for master node"
  type        = string
  default     = "root"
}

variable "ssh_host" {
  description = "Mapping of IP addresses to node names"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the private key for SSH access to the master node"
  type        = string
}

variable "k8s_master_ips" {
  type = list(string)
  description = "Danh sách IP các node master"
}


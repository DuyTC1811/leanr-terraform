variable "master_ip" {
  description = "IP master node"
  type        = string
}

variable "ssh_user" {
  description = "SSH user for master node"
  type        = string
  default     = "root"
}

variable "ssh_private_key_path" {
  description = "Path to the private key for SSH access to the master node"
  type        = string
}

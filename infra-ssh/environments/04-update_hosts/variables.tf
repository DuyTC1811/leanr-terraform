variable "ssh_hosts" {
  description = "Map of SSH hosts with user and host information"
  type = map(object({
    ssh_user = string
    ssh_host = string
  }))
}

variable "ssh_private_key_path" {
  description = "Path to the private key for SSH access to the master node"
  type        = string
}

variable "node_map" {
  description = "Mapping of IP addresses to node names"
  type        = map(string)
}


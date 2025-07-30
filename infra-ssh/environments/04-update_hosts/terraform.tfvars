ssh_user = "debian"
ssh_host = "192.168.1.50" # Example IP Loadbalance, replace with actual
node_map = {
  "192.168.1.50" = "etcd"
}
ssh_private_key_path = "../../common-key/id_rsa_dev"

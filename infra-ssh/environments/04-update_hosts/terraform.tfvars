ssh_user = "debian"
ssh_host = "192.168.1.50" # Example IP Loadbalance, replace with actual
node_map = {
  "192.168.1.51" = "etcd"
  "192.168.1.52" = "master"
  "192.168.1.53" = "worker-1"
  "192.168.1.54" = "worker-2"
  "192.168.1.55" = "worker-3"
}
ssh_private_key_path = "../../common-key/id_rsa_dev"

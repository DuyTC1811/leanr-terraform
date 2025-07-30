ssh_user = "debian"

node_map = {
  "192.168.1.51" = "etcd"
  "192.168.1.52" = "master"
  "192.168.1.53" = "worker-1"
  "192.168.1.54" = "worker-2"
  "192.168.1.55" = "worker-3"
}

ssh_private_key_path       = "../../common-key/id_rsa_dev"
certificates_ca_path       = "../../common-key/openssl/ca.pem"
certificates_etcd_path     = "../../common-key/openssl/etcd.pem"
certificates_etcd_key_path = "../../common-key/openssl/etcd-key.pem"
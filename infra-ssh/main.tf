module "generate_certificates" {
  source = "./environments/01-generate-certificates"
}

module "loadbalancer" {
  source     = "./environments/02-loadbalance"
  depends_on = [module.generate_certificates]

  ssh_host             = "192.168.1.50"
  ssh_private_key_path = "./common-key/id_rsa_dev"
  k8s_master_ips       = ["192.168.1.52"]
}

module "setup_etcd" {
  source                     = "./environments/03-setup-etcd"
  depends_on                 = [module.loadbalancer]
  ssh_user                   = "debian"
  ssh_host                   = "192.168.1.51"
  ssh_private_key_path       = "./common-key/id_rsa_dev"
  certificates_ca_path       = "./openssl/ca.pem"
  certificates_etcd_path     = "./openssl/etcd.pem"
  certificates_etcd_key_path = "./openssl/etcd-key.pem"
}

module "update_hosts" {
  source     = "./environments/04-update_hosts"
  depends_on = [module.setup_etcd]
  ssh_hosts = {
    "master" = {
      ssh_user = "debian"
      ssh_host = "192.168.1.50"
    }
    "worker-01" = {
      ssh_user = "debian"
      ssh_host = "192.168.1.51"
    }
    "worker-02" = {
      ssh_user = "debian"
      ssh_host = "192.168.1.52"
    }
  }

  node_map = {
    "192.168.1.52" = "master"
    "192.168.1.53" = "worker-1"
    "192.168.1.54" = "worker-2"
    "192.168.1.55" = "worker-3"
  }
  ssh_private_key_path = "./common-key/id_rsa_dev"
}

module "setup_nodes" {
  source     = "./environments/05-setup-nodes"
  depends_on = [module.update_hosts]

  node_map = {
    "192.168.1.52" = "master"
    "192.168.1.53" = "worker-1"
    "192.168.1.54" = "worker-2"
    "192.168.1.55" = "worker-3"
  }
  ssh_private_key_path       = "./common-key/id_rsa_dev"
  certificates_ca_path       = "./openssl/ca.pem"
  certificates_etcd_path     = "./openssl/etcd.pem"
  certificates_etcd_key_path = "./openssl/etcd-key.pem"
}

# module "join_nodes" {
#   source     = "./environments/06-join-nodes"
#   depends_on = [module.setup_nodes]

#   ssh_host             = var.ssh_host
#   ssh_private_key_path = var.ssh_private_key_path
# }

# module "setup_network" {
#   source     = "./environments/07-setup-network"
#   depends_on = [module.join_nodes]

#   ssh_host             = var.ssh_host
#   ssh_private_key_path = var.ssh_private_key_path
# }

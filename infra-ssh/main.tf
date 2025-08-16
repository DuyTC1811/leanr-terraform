module "generate_certificates" {
  source = "./environments/01-generate-certificates"
}

module "loadbalancer" {
  source               = "./environments/02-loadbalance"
  depends_on           = [module.generate_certificates]
  ssh_user             = "debian"
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
  certificates_ca_path       = "./common-key/openssl/ca.pem"
  certificates_etcd_path     = "./common-key/openssl/etcd.pem"
  certificates_etcd_key_path = "./common-key/openssl/etcd-key.pem"
}

module "update_hosts" {
  source     = "./environments/04-update_hosts"
  depends_on = [module.setup_etcd]
  ssh_hosts = {
    "master" = {
      ssh_user = "debian"
      ssh_host = "192.168.1.52"
    }
    "worker-01" = {
      ssh_user = "debian"
      ssh_host = "192.168.1.53"
    }
    "worker-02" = {
      ssh_user = "debian"
      ssh_host = "192.168.1.54"
    }
    "worker-03" = {
      ssh_user = "debian"
      ssh_host = "192.168.1.55"
    }
    "worker-04" = {
      ssh_user = "debian"
      ssh_host = "192.168.1.56"
    }
  }

  node_map = {
    "192.168.1.52" = "master"
    "192.168.1.53" = "worker-01"
    "192.168.1.54" = "worker-02"
    "192.168.1.55" = "worker-03"
    "192.168.1.56" = "worker-04"
  }

  ssh_private_key_path = "./common-key/id_rsa_dev"
}

module "setup_nodes" {
  source     = "./environments/05-setup-nodes"
  depends_on = [module.update_hosts]
  ssh_user                   = "debian"
  node_map = {
    "192.168.1.52" = "master"
    "192.168.1.53" = "worker-01"
    "192.168.1.54" = "worker-02"
    "192.168.1.55" = "worker-03"
    "192.168.1.56" = "worker-04"
  }

  ssh_private_key_path       = "./common-key/id_rsa_dev"
  certificates_ca_path       = "./common-key/openssl/ca.pem"
  certificates_etcd_path     = "./common-key/openssl/etcd.pem"
  certificates_etcd_key_path = "./common-key/openssl/etcd-key.pem"
}

module "join_nodes" {
  source     = "./environments/06-init-node"
  depends_on = [module.setup_nodes]

  ssh_user = "debian"
  node_map = {
    "192.168.1.52" = "master"
    "192.168.1.53" = "worker-01"
    "192.168.1.54" = "worker-02"
    "192.168.1.55" = "worker-03"
    "192.168.1.56" = "worker-04"
  }
  ssh_private_key_path = "./common-key/id_rsa_dev"
}

# module "setup_network" {
#   source     = "./environments/07-setup-network"
#   depends_on = [module.join_nodes]

#   ssh_host             = var.ssh_host
#   ssh_private_key_path = var.ssh_private_key_path
# }

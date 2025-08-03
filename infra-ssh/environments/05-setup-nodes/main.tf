resource "null_resource" "setup_nodes" {
  for_each = var.node_map

  connection {
    type        = "ssh"
    host        = each.key
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  # Copy certificates
  provisioner "file" {
    source      = var.certificates_ca_path
    destination = "/tmp/ca.pem"
  }

  # Copy etcd certificate
  provisioner "file" {
    source      = var.certificates_etcd_path
    destination = "/tmp/etcd.pem"
  }

  # Copy etcd private key`
  provisioner "file" {
    source      = var.certificates_etcd_key_path
    destination = "/tmp/etcd-key.pem"
  }

  provisioner "file" {
    source      = "${path.module}/kubea-install.sh"
    destination = "/tmp/kubea-install.sh"
  }

  provisioner "file" {
    source      = "${path.module}/gen-kubeadm-config.sh"
    destination = "/tmp/gen-kubeadm-config.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/kubea-install.sh /tmp/gen-kubeadm-config.sh",
      "if [ \"${each.value}\" = \"master\" ]; then",
      "  echo '[INFO] Installing master...${each.value}'",
      "  sudo mkdir -p /etc/kubernetes/pki/etcd/",
      "  sudo /tmp/kubea-install.sh ${each.value}",
      "  sudo mv /tmp/ca.pem /etc/kubernetes/pki/etcd/",
      "  sudo mv /tmp/etcd.pem /etc/kubernetes/pki/etcd/",
      "  sudo mv /tmp/etcd-key.pem /etc/kubernetes/pki/etcd/",

      "  sudo /tmp/gen-kubeadm-config.sh \\",
      "  9a08jv.c0izixklcxtmnze7 \\",                 # Token for the control plane
      "  192.168.1.52 \\",                            # IP of the master node
      "  master \\",                                  # Role of the node
      "  192.168.1.50 \\",                            # IP of the control plane endpoint
      "  192.168.1.50,master,localhost,127.0.0.1 \\", # Control plane endpoint IPs
      "  192.168.1.51",                               # IP of the etcd node
      "  sudo kubeadm init --config=/tmp/kubeadm-config.yaml --upload-certs",

      "  mkdir -p $HOME/.kube",
      "  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "  sudo chown $(id -u):$(id -g) $HOME/.kube/config",
      "  sudo reboot",
      "else",
      "  echo '[INFO] Installing worker...${each.value}'",
      "  sudo /tmp/kubea-install.sh ${each.value}",
      "  sudo reboot",
      "fi"
    ]
  }

}

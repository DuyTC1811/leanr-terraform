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

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/kubea-install.sh",
      "if [ \"$ROLE\" = \"master\" ]; then",
      "  echo '[INFO] Installing master...${each.value}'",
      "  sudo mkdir -vp /etc/kubernetes/pki/etcd/",
      "  sudo /tmp/kubea-install.sh ${each.value}",
      "  sudo mv /tmp/ca.pem /etc/kubernetes/pki/etcd/ca.pem",
      "  sudo mv /tmp/etcd.pem /etc/kubernetes/pki/etcd/etcd.pem",
      "  sudo mv /tmp/etcd-key.pem /etc/kubernetes/pki/etcd/etcd-key.pem",
      "else",
      "  echo '[INFO] Installing worker...${each.value}'",
      "  sudo /tmp/kubea-install.sh ${each.value}",
      "fi"
    ]
  }

}

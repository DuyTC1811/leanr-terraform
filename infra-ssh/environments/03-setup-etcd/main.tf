resource "null_resource" "setup_etcd" {
  connection {
    type        = "ssh"
    host        = var.ssh_host
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  # Copy install ETCD script
  provisioner "file" {
    source      = "01-install-etcd.sh"
    destination = "/tmp/01-install-etcd.sh"
  }

  # Copy setup service ETCD script
  provisioner "file" {
    source      = "02-setup-service-etcd.sh"
    destination = "/tmp/02-setup-service-etcd.sh"
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
      "chmod +x /tmp/01-install-etcd.sh /tmp/02-setup-service-etcd.sh",
      "sudo /tmp/01-install-etcd.sh",
      "sudo /tmp/02-setup-service-etcd.sh"
    ]
  }
}


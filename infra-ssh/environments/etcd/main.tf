resource "null_resource" "etcd" {
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    host        = var.ssh_host_etcd
  }

  # Copy install script
  provisioner "file" {
    source      = "install-etcd.sh"
    destination = "/tmp/install-etcd.sh"
  }

  # Copy setup service script
  provisioner "file" {
    source      = "setup-service-etcd.sh"
    destination = "/tmp/setup-service-etcd.sh"
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

  # Copy etcd private key
  provisioner "file" {
    source      = var.certificates_etcd_key_path
    destination = "/tmp/etcd-key.pem"
  }

  # Execute both scripts remotely
  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/ca.pem /var/lib/etcd/ca.pem",
      "sudo mv /tmp/etcd.pem /var/lib/etcd/etcd.pem",
      "sudo mv /tmp/etcd-key.pem /var/lib/etcd/etcd-key.pem",

      "chmod +x /tmp/install-etcd.sh /tmp/setup-service-etcd.sh",
      "sudo /tmp/install-etcd.sh",
      "sudo /tmp/setup-service-etcd.sh"
    ]
  }
}

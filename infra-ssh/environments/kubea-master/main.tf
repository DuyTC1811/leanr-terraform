resource "null_resource" "install_k8s_master" {
  connection {
    type        = "ssh"
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
    host        = var.master_ip
  }

  # Copy install script
  provisioner "file" {
    source      = "kubea-install.sh"
    destination = "/tmp/kubea-install.sh"
  }

  # Execute both scripts remotely
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/kubea-install.sh",
      "sudo /tmp/kubea-install.sh"
    ]
  }
}

resource "null_resource" "install_haproxy" {
  connection {
    type        = "ssh"
    host        = var.ssh_host
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "install-haproxy.sh"
    destination = "/tmp/install-haproxy.sh"
  }

    provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-haproxy.sh",
      "sudo /tmp/install-haproxy.sh '${join(" ", var.k8s_master_ips)}'"
    ]
  }
}

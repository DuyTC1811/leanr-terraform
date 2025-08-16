resource "null_resource" "init_master" {
  for_each = {
    for key, value in var.node_map : key => value if value == "master"
  }

  connection {
    type        = "ssh"
    host        = each.key
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  # Khởi tạo master node bằng kubeadm init
  provisioner "remote-exec" {
    inline = [
      ""
    ]
  }
}

# kubeadm init phase upload-certs --upload-certs # Lấy certificate key để join worker nodes
# kubeadm token create --print-join-command # Lấy join command để join worker nodes
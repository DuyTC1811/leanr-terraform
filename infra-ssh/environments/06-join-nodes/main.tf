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

  # Copy file cấu hình kubeadm (đã render từ template nếu cần)
  provisioner "file" {
    source      = "gen-kubeadm-config"
    destination = "/tmp/gen-kubeadm-config"
  }

  # Khởi tạo master node bằng kubeadm init
  provisioner "remote-exec" {
    inline = [
      "echo '[INFO] Initializing Kubernetes master node on ${each.key}'",
      "sudo kubeadm init --config=/tmp/kubeadm-config.yaml --upload-certs",

      # Cấu hình kubectl cho user
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config"
    ]
  }
}

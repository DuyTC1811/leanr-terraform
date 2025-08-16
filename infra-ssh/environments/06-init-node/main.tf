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
    source      = "${path.module}/gen-kubeadm-config.sh"
    destination = "/tmp/gen-kubeadm-config.sh"
  }

  # Khởi tạo master node bằng kubeadm init
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/gen-kubeadm-config.sh",
      "sudo /tmp/gen-kubeadm-config.sh \\",
      "  9a08jv.c0izixklcxtmnze7 \\",                 # Token for the control plane
      "  192.168.1.52 \\",                            # IP of the master node
      "  master \\",                                  # Role of the node
      "  192.168.1.50 \\",                            # IP of the control plane endpoint
      "  192.168.1.50,master,localhost,127.0.0.1 \\", # Control plane endpoint IPs
      "  192.168.1.51",                               # IP of the etcd node
      "sudo kubeadm init --config=/tmp/kubeadm-config.yaml --upload-certs",
      "mkdir -p $HOME/.kube",
      "sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config",
      "sudo chown $(id -u):$(id -g) $HOME/.kube/config",
    ]
  }
}

# kubeadm init phase upload-certs --upload-certs # Lấy certificate key để join worker nodes
# kubeadm token create --print-join-command # Lấy join command để join worker nodes
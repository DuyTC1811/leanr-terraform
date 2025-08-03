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
      "echo '[INFO] Initializing master node... ${each.key}'",
      "sudo /tmp/gen-kubeadm-config.sh ",               # Token for the control plane
      "helm repo add cilium https://helm.cilium.io/",
      "helm repo update",
      "helm install cilium cilium/cilium --namespace kube-system -f /tmp/cilium-value.yaml",
    ]
  }
}

# kubeadm init phase upload-certs --upload-certs # Lấy certificate key để join worker nodes
# kubeadm token create --print-join-command # Lấy join command để join worker nodes
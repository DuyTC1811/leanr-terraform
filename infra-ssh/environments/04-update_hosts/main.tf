resource "null_resource" "append_hosts" {
  for_each = var.node_map

  connection {
    type        = "ssh"
    host        = each.key
    user        = var.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      <<EOT
          if ! grep -qE "^${each.key}\\s+${each.value}" /etc/hosts; then
            echo "${each.key}    ${each.value}" | sudo tee -a /etc/hosts
          fi
        EOT
    ]
  }
}

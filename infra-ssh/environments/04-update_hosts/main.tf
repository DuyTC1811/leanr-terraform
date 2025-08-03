resource "null_resource" "append_hosts" {
  for_each = var.ssh_hosts

  connection {
    host        = each.value.ssh_host
    user        = each.value.ssh_user
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      join("\n", [
        for ip, name in var.node_map :
        <<EOT
        if ! grep -qE "^${ip}\\s+${name}" /etc/hosts; then
          echo "${ip}    ${name}" | sudo tee -a /etc/hosts
        fi
        EOT
      ])
    ]
  }
}

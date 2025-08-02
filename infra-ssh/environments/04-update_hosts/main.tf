resource "null_resource" "append_hosts" {
  for_each = var.node_map

  connection {
    type        = "ssh"
    host        = lookup(var.ssh_hosts, each.key, null)["ssh_host"]
    user        = lookup(var.ssh_hosts, each.key, null)["ssh_user"]
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

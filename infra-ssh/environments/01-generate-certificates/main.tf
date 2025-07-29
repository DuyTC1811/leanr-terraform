resource "null_resource" "generate_certificates" {
  provisioner "local-exec" {
    command = "sh generate-certificates.sh ../../common-key"
  }
}

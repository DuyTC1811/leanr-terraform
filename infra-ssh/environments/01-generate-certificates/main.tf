resource "null_resource" "generate_certificates" {
  provisioner "local-exec" {
    command = "sh ${path.module}/generate-certificates.sh ${path.module}/../../common-key"
  }
}

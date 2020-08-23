variable "connection" {
  type = map(any)
}

variable "MEM_LIMIT" {
    type = string
    default = "40M"
}

variable "COMP_ALG" {
    type = string
    default = "lz4"
}

variable "DISK_SIZE" {
    type = string
    default = "100M"
}

variable "depends" {
  default = []
}

# warning! the outputs are not updated even if the trigger re-runs the command!
variable "trigger" {
  default = ""
}

locals {
    tempFolder = "/tmp/zramswap/"
}

resource "null_resource" "zramswap_install" {
  triggers = {}
  depends_on = [var.depends]

  connection {
    // Source <https://www.terraform.io/docs/provisioners/connection.html#argument-reference>
    type     = try(var.connection["type"], null)
    user     = try(var.connection["user"], null)
    password = try(var.connection["password"], null)
    host     = var.connection["host"] //Required
    port     = try(var.connection["port"], null)
    timeout  = try(var.connection["timeout"], null)

    private_key    = try(var.connection["private_key"], null)
    certificate    = try(var.connection["certificate"], null)
    agent          = try(var.connection["agent"], null)
    agent_identity = try(var.connection["agent_identity"], null)
    host_key       = try(var.connection["host_key"], null)

    https    = try(var.connection["https"], null)
    insecure = try(var.connection["insecure"], null)
    use_ntlm = try(var.connection["use_ntlm"], null)
    cacert   = try(var.connection["cacert"], null)

    bastion_host        = try(var.connection["bastion_host"], null)
    bastion_host_key    = try(var.connection["bastion_host_key"], null)
    bastion_port        = try(var.connection["bastion_port"], null)
    bastion_user        = try(var.connection["bastion_user"], null)
    bastion_password    = try(var.connection["bastion_password"], null)
    bastion_private_key = try(var.connection["bastion_private_key"], null)
    bastion_certificate = try(var.connection["bastion_certificate"], null)
  }

  provisioner "file" {
    source      = "${path.module}/scripts"
    destination = local.tempFolder
  }

  provisioner "remote-exec" {
    inline = [
      #"systemctl -q is-active zramswap  && { echo \"ERROR: zramswap service is still running. Please run \\\"sudo service zramswap stop\\\" to stop it.\"; exit 1; }",
      "sudo mkdir -p /usr/local/bin/",
      "sudo install -m 644 ${local.tempFolder}zramswap.service /etc/systemd/system/zramswap.service",
      "sudo install -m 755 ${local.tempFolder}zramswap /usr/local/bin/zramswap",
      "sudo install -m 644 ${local.tempFolder}zramswap.conf /etc/zramswap.conf",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable zramswap.service",
      "rm -rf ${local.tempFolder}",
    ]
  }
}

resource "null_resource" "zramswap_config" {
  triggers = {
    trigger   = var.trigger
    SIZE      = var.MEM_LIMIT
    COMP_ALG= var.COMP_ALG
    DISK_SIZE = var.DISK_SIZE
  }
  depends_on = [var.depends, null_resource.zramswap_install]

  connection {
    // Source <https://www.terraform.io/docs/provisioners/connection.html#argument-reference>
    type     = try(var.connection["type"], null)
    user     = try(var.connection["user"], null)
    password = try(var.connection["password"], null)
    host     = var.connection["host"] //Required
    port     = try(var.connection["port"], null)
    timeout  = try(var.connection["timeout"], null)

    private_key    = try(var.connection["private_key"], null)
    certificate    = try(var.connection["certificate"], null)
    agent          = try(var.connection["agent"], null)
    agent_identity = try(var.connection["agent_identity"], null)
    host_key       = try(var.connection["host_key"], null)

    https    = try(var.connection["https"], null)
    insecure = try(var.connection["insecure"], null)
    use_ntlm = try(var.connection["use_ntlm"], null)
    cacert   = try(var.connection["cacert"], null)

    bastion_host        = try(var.connection["bastion_host"], null)
    bastion_host_key    = try(var.connection["bastion_host_key"], null)
    bastion_port        = try(var.connection["bastion_port"], null)
    bastion_user        = try(var.connection["bastion_user"], null)
    bastion_password    = try(var.connection["bastion_password"], null)
    bastion_private_key = try(var.connection["bastion_private_key"], null)
    bastion_certificate = try(var.connection["bastion_certificate"], null)
  }

  provisioner "remote-exec" {
    inline = [
      "free -h",
      "sudo service zramswap stop",
      "sudo sed -i \"s/^MEM_LIMIT=.*$/MEM_LIMIT=${var.MEM_LIMIT}/g\" /etc/zramswap.conf",
      "sudo sed -i \"s/^COMP_ALG=.*$/COMP_ALG=${var.COMP_ALG}/g\" /etc/zramswap.conf",
      "sudo sed -i \"s/^DISK_SIZE=.*$/DISK_SIZE=${var.DISK_SIZE}/g\" /etc/zramswap.conf",
      "cat /etc/zramswap.conf",
      "sudo service zramswap start",
      "free -h",
    ]
  }
}

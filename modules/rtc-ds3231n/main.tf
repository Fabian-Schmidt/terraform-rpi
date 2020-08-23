variable "connection" {
  type = map(any)
}

variable "depends" {
  default = []
}

# warning! the outputs are not updated even if the trigger re-runs the command!
variable "trigger" {
  default = ""
}

locals {
  tempFolder = "/tmp/rtc-ds3231n/"
}

resource "null_resource" "rtc-ds3231n" {
  triggers = {
    trigger       = var.trigger
  }
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
      # activate i2c on raspberry
      "if grep -q 'dtparam=i2c_arm=on' /boot/cmdline.txt; then",
      "  echo 'dtparam=i2c_arm=on found in /boot/cmdline.txt'",
      "else",
      "  echo 'dtparam=i2c_arm=on not found in /boot/cmdline.txt'",
      "  cat /boot/cmdline.txt",
      "  sudo sed -i -e '1s/$/ dtparam=i2c_arm=on/g' /boot/cmdline.txt",
      "  cat /boot/cmdline.txt",
      "fi",

      "sudo apt install i2c-tools -y",

      "sudo install -m 644 ${local.tempFolder}modules-load.d/rtc-i2c.conf /etc/modules-load.d/rtc-i2c.conf",
      "sudo install -m 644 ${local.tempFolder}rtc-i2c.conf /etc/rtc-i2c.conf",
      "sudo install -m 755 ${local.tempFolder}rtc-i2c.rules /etc/udev/rules.d/rtc-i2c.rules",
      "sudo install -m 755 ${local.tempFolder}rtc-i2c.service /etc/systemd/system/rtc-i2c.service",
      "sudo systemctl daemon-reload",
      "sudo systemctl enable rtc-i2c.service",
      
      "rm -rf ${local.tempFolder}",
    ]
  }
}
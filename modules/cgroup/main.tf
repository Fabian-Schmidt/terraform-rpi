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

locals {}

resource "null_resource" "cgroup" {
  triggers = {
    trigger = var.trigger
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

  provisioner "remote-exec" {
    inline = [
      "if grep -q 'cgroup_enable=cpuset' /boot/cmdline.txt; then",
      "  echo 'cgroup_enable=cpuset found in /boot/cmdline.txt'",
      "else",
      "  echo 'cgroup_enable=cpuset not found in /boot/cmdline.txt'",
      "  cat /boot/cmdline.txt",
      "  sudo sed -i -e '1s/$/ cgroup_enable=cpuset/g' /boot/cmdline.txt",
      "  cat /boot/cmdline.txt",
      "fi",

      "if grep -q 'cgroup_enable=memory' /boot/cmdline.txt; then",
      "  echo 'cgroup_enable=memory found in /boot/cmdline.txt'",
      "else",
      "  echo 'cgroup_enable=memory not found in /boot/cmdline.txt'",
      "  cat /boot/cmdline.txt",
      "  sudo sed -i -e '1s/$/ cgroup_enable=memory/g' /boot/cmdline.txt",
      "  cat /boot/cmdline.txt",
      "fi",

      "if grep -q 'cgroup_memory=1' /boot/cmdline.txt; then",
      "  echo 'cgroup_memory found in /boot/cmdline.txt'",
      "else",
      "  echo 'cgroup_memory not found in /boot/cmdline.txt'",
      "  cat /boot/cmdline.txt",
      "  sudo sed -i -e '1s/$/ cgroup_memory=1/g' /boot/cmdline.txt",
      "  cat /boot/cmdline.txt",
      "fi",
    ]
  }
}


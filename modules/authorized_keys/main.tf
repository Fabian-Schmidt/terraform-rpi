#IN
variable "connection" {
  type = map(any)
}

variable "ssh_public_key" {
  type = string
}

variable "depends" {
  default = []
}

# warning! the outputs are not updated even if the trigger re-runs the command!
variable "trigger" {
  default = ""
}


locals {}

resource "null_resource" "authorized_keys" {
  triggers = {
    trigger        = var.trigger
    ssh_public_key = var.ssh_public_key
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

  #Copy file
  #provisioner "file" {
  #  source      = var.ssh_public_key
  #  destination = "/tmp/id_rsa.pub"
  #}

  provisioner "remote-exec" {
    inline = [
      #create .ssh folder in home folder
      "mkdir -vp ~/.ssh",
      #write public key to /home/pi/.ssh/authorized_keys
      "echo >> ~/.ssh/authorized_keys",
      "echo \"${var.ssh_public_key}\" >> ~/.ssh/authorized_keys",
      "echo >> ~/.ssh/authorized_keys",
      #"cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys",
      ##delete tmp file
      #"sudo rm -fv /tmp/id_rsa.pub"
    ]
  }
}

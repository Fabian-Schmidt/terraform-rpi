variable "ip_adress" {}

variable "k3s_master_ip" {}

variable "k3s_master_token" {}

variable "hostname" {
  default = "rpi-host"
}

variable "timezone" {
  default = "Europe/London"
}

variable "initial_user" {
  default = "pi"
}

variable "initial_password" {
  default = "raspberry"
}

variable "ssh_public_key" {}

variable "ssh_private_key" {}
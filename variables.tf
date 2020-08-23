variable "ip_adress" {}

variable "k3s_servernode" {
  type = bool
  default = false
}

variable "k3s_workernode" {
  type = bool
  default = false
}

variable "k3s_master_ip" {
  type = string
}

variable "k3s_master_token" {
  type = string
}

variable "hostname" {
  default = "rpi-host"
}

variable "hasRTC" {
  type = bool
  default = false
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

variable "reboot_waittime" {
  type = number
  default = 30
}
variable "ip_adress" {
  type = string
}

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
  type = string
  default = "rpi-host"
}

variable "hasRTC" {
  type = bool
  default = false
}

variable "useZram" {
  type = bool
  default = true
}

variable "timezone" {
  type = string
  default = "Europe/London"
}

variable "initial_user" {
  type = string
  default = "pi"
}

variable "initial_password" {
  type = string
  default = "raspberry"
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_private_key" {
  type = string
}
variable "reboot_waittime" {
  type = number
  default = 30
}
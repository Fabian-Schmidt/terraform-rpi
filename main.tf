# Raspberry Pi Terraform Bootstrap Provisioner (Tested with Raspbian Stretch).
# This is a run-once bootstrap Terraform provisioner for a Raspberry Pi.  
# Provisioners by default run only at resource creation, additional runs without cleanup may introduce problems.
# https://www.terraform.io/docs/provisioners/index.html
locals {
  ssh_timeout   = "10s"
  default_sleep = "1s"

  connectionpw = {
    type     = "ssh"
    host     = var.ip_adress
    user     = var.initial_user
    password = var.initial_password
    timeout  = local.ssh_timeout
  }

  connectionkey = {
    type     = "ssh"
    host     = var.ip_adress
    user     = var.initial_user
    private_key = var.ssh_private_key
    timeout  = local.ssh_timeout
  }

  connectionkey_k3s_server = {
    type     = "ssh"
    host     = var.k3s_master_ip
    user     = var.initial_user
    private_key = var.ssh_private_key
    timeout  = local.ssh_timeout
  }
}

module "authorized_keys" {
  source = "./modules/authorized_keys"
  connection = local.connectionpw

  ssh_public_key = var.ssh_public_key
}

module "apt_upgrade" {
  source = "./modules/apt_upgrade"
  connection = local.connectionkey

  depends = [
    module.authorized_keys,
  ]
}

module "apt_install" {
  source = "./modules/apt_install"
  connection = local.connectionkey

  install = "ncdu htop nano mc iotop"

  depends = [
    module.authorized_keys,
    module.apt_upgrade,
  ]
}

module "hostname" {
  source = "./modules/hostname"
  connection = local.connectionkey

  hostname = var.hostname

  depends = [
    module.authorized_keys,
    module.apt_upgrade,
    module.apt_install,
  ]
}

module "timezone" {
  source = "./modules/timezone"
  connection = local.connectionkey

  timezone = var.timezone

  depends = [
    module.authorized_keys,
    module.apt_upgrade,
    module.apt_install,
    module.hostname,
  ]
}

module "disableswap" {
  source = "./modules/disableswap"
  connection = local.connectionkey

  depends = [
    module.authorized_keys,
    module.apt_upgrade,
    module.apt_install,
    module.hostname,
    module.timezone,
  ]
}

module "log2ram" {
  source = "./modules/log2ram"
  connection = local.connectionkey

  ZL2R = var.useZram

  depends = [
    module.authorized_keys,
    module.apt_upgrade,
    module.apt_install,
    module.hostname,
    module.timezone,
    module.disableswap,
  ]
}

module "zramswap" {
  source = "./modules/zramswap"
  connection = local.connectionkey
  count = var.useZram == true ? 1 : 0

  depends = [
    module.authorized_keys,
    module.apt_upgrade,
    module.apt_install,
    module.hostname,
    module.timezone,
    module.disableswap,
    module.log2ram,
  ]
}

module "syncthing" {
  source = "./modules/syncthing"
  connection = local.connectionkey

  listenIp = "0.0.0.0"

  depends = [
    module.authorized_keys,
    module.apt_upgrade,
    module.apt_install,
    module.hostname,
    module.timezone,
    module.disableswap,
    module.log2ram,
    module.zramswap,
  ]
}

module "cgroup" {
  source = "./modules/cgroup"
  connection = local.connectionkey

  depends = [
    module.authorized_keys,
    module.apt_upgrade,
    module.apt_install,
    module.hostname,
    module.timezone,
    module.disableswap,
    module.log2ram,
    module.zramswap,
    module.syncthing,
  ]
}

module "rtc-ds3231n" {
  source = "./modules/rtc-ds3231n"
  connection = local.connectionkey
  count = var.hasRTC == true ? 1 : 0

  depends = [
    module.authorized_keys,
    module.apt_upgrade,
    module.apt_install,
    module.hostname,
    module.timezone,
    module.disableswap,
    module.log2ram,
    module.zramswap,
    module.syncthing,
    module.cgroup,
  ]
}

module "reboot" {
  source = "./modules/reboot"
  connection = local.connectionkey

  reboot_waittime = var.reboot_waittime
  
  depends = [
    module.authorized_keys,
    module.apt_upgrade,
    module.apt_install,
    module.hostname,
    module.timezone,
    module.disableswap,
    module.log2ram,
    module.zramswap,
    module.syncthing,
    module.cgroup,
    module.rtc-ds3231n,
  ]
}

module "k3s_install_servernode" {
  source = "./modules/k3s_install_servernode"
  connection = local.connectionkey
  count = var.k3s_servernode == true ? 1 : 0

  depends = [
    module.authorized_keys,
    module.apt_upgrade,
    module.apt_install,
    module.hostname,
    module.timezone,
    module.disableswap,
    module.log2ram,
    module.zramswap,
    module.syncthing,
    module.cgroup,
    module.rtc-ds3231n,
    module.reboot,
  ]
}

module "k3s_install_workernode" {
  source = "./modules/k3s_install_workernode"
  connection = local.connectionkey
  count = var.k3s_workernode == true ? 1 : 0
  
  master_ip = var.k3s_master_ip
  master_token = var.k3s_master_token

  depends = [
    module.authorized_keys,
    module.apt_upgrade,
    module.apt_install,
    module.hostname,
    module.timezone,
    module.disableswap,
    module.log2ram,
    module.zramswap,
    module.syncthing,
    module.cgroup,
    module.rtc-ds3231n,
    module.reboot,
  ]
}

module "k3s_nodelist" {
  source = "./modules/k3s_nodelist"
  connection = local.connectionkey_k3s_server
  
  depends = [
    module.authorized_keys,
    module.apt_upgrade,
    module.apt_install,
    module.hostname,
    module.timezone,
    module.disableswap,
    module.log2ram,
    module.zramswap,
    module.syncthing,
    module.cgroup,
    module.rtc-ds3231n,
    module.reboot,
    module.k3s_install_servernode,
    module.k3s_install_workernode,
  ]
}
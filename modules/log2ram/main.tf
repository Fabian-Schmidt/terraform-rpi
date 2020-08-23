variable "connection" {
  type = map(any)
}

variable "SIZE" {
    type = string
    default = "40M"
    description = <<EOF
Size for the ram folder, it defines the size the log folder will reserve into the RAM.
If it's not enough, log2ram will not be able to use ram. Check you /var/log size folder.
The default is 40M and is basically enough for a lot of applications.
You will need to increase it if you have a server and a lot of log for example.
EOF
}

variable "PATH_DISK" {
    type = string
    default = "/var/log"
    description = <<EOF
Variable for folders to put in RAM. You need to specify the real folder `/path/folder` , the `/path/hdd.folder` will be automatically created. Multiple path can be separeted by `;`. Do not add the final `/` !
example : PATH_DISK="/var/log;/home/test/FolderInRam"
EOF
}

variable "ZL2R" {
    type = bool
    default = true
    description = <<EOF
ZL2R Zram Log 2 Ram enables a zram drive when ZL2R=true ZL2R=false is mem only tmpfs
EOF
}

variable "COMP_ALG" {
    type = string
    default = "lz4"
    description = <<EOF
COMP_ALG this is any compression algorithm listed in /proc/crypto
lz4 is fastest with lightest load but deflate (zlib) and Zstandard (zstd) give far better compression ratios
lzo is very close to lz4 and may with some binaries have better optimisation
COMP_ALG=lz4 for speed or Zstd for compression, lzo or zlib if optimisation or availabilty is a problem
EOF
}

variable "LOG_DISK_SIZE" {
    type = string
    default = "100M"
    description = <<EOF
LOG_DISK_SIZE is the uncompressed disk size. Note zram uses about 0.1% of the size of the disk when not in use
LOG_DISK_SIZE is expected compression ratio of alg chosen multiplied by log SIZE
lzo/lz4=2.1:1 compression ratio zlib=2.7:1 zstandard=2.9:1
Really a guestimate of a bit bigger than compression ratio whilst minimising 0.1% mem usage of disk size
EOF
}

variable "depends" {
  default = []
}

# warning! the outputs are not updated even if the trigger re-runs the command!
variable "trigger" {
  default = ""
}

locals {
    PATH_DISK_Escaped = replace(var.PATH_DISK, "\\/", "\\/")
}

resource "null_resource" "log2ram" {
  triggers = {
    trigger       = var.trigger
    SIZE          = var.SIZE
    PATH_DISK     = var.PATH_DISK
    ZL2R          = var.ZL2R
    COMP_ALG      = var.COMP_ALG
    LOG_DISK_SIZE = var.LOG_DISK_SIZE
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
      "echo \"deb http://packages.azlux.fr/debian/ buster main\" | sudo tee /etc/apt/sources.list.d/azlux.list",
      "wget -qO - https://azlux.fr/repo.gpg.key | sudo apt-key add -",
      "sudo apt update",
      "sudo apt install rsync log2ram -y",
      # activate rsync
      "sudo sed -i \"s/^USE_RSYNC=false/USE_RSYNC=true/g\" /etc/log2ram.conf",
      # disable mail
      "sudo sed -i \"s/^MAIL=true/MAIL=false/g\" /etc/log2ram.conf",
      # activate zram
      "sudo sed -i \"s/^ZL2R=.*/ZL2R=${tostring(var.ZL2R)}/g\" /etc/log2ram.conf",
      # configuration
      "sudo sed -i \"s/^SIZE=.*$/SIZE=${var.SIZE}/g\" /etc/log2ram.conf",
      "sudo sed -i \"s/^PATH_DISK=\\\".*\\\"$/PATH_DISK=\\\"${local.PATH_DISK_Escaped}\\\"/g\" /etc/log2ram.conf",
      "sudo sed -i \"s/^COMP_ALG=.*$/COMP_ALG=${var.COMP_ALG}/g\" /etc/log2ram.conf",
      "sudo sed -i \"s/^LOG_DISK_SIZE=.*$/LOG_DISK_SIZE=${var.LOG_DISK_SIZE}/g\" /etc/log2ram.conf",
      "cat /etc/log2ram.conf",
    ]
  }
}

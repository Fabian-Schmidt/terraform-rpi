# CONNECTION PARAMETERS
ip_adress = "192.168.10.22"

# How much time to give the Pi to restart
reboot_waittime = 40

# Either Server or Worker node.
k3s_servernode = true
k3s_workernode = false
# Worker needs parameter `k3s_master_ip` and `k3s_master_token`
k3s_master_ip = "192.168.10.22"
k3s_master_token = ""

# CONIGURATION PARAMETERS
hostname = "Raspi4-01"

hasRTC = true
# My Raspberry Pi always gives me a Kernel panic when I load the zram module.
useZram = false

# Validate timezone correctness against 'timedatectl list-timezones' 
timezone = "Europe/Berlin"

ssh_public_key = <<-EOF
ssh-rsa AAAA...
EOF

ssh_private_key = <<-EOF
-----BEGIN RSA PRIVATE KEY-----

-----END RSA PRIVATE KEY-----
EOF


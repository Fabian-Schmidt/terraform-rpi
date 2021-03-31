# CONNECTION PARAMETERS
ip_adress = "192.168.10.20"

# How much time to give the Pi to restart
reboot_waittime = 40

# Either Server or Worker node.
k3s_servernode = false
k3s_workernode = true
# Worker needs parameter `k3s_master_ip` and `k3s_master_token`
k3s_master_ip = "192.168.10.22"
k3s_master_token = "K103093f1b166ee5902d9d4a8a741472b4314b7edda42b94632ace9c44839c4019f::server:30de4007ebdd0ae37d79473c37011a78"

# CONIGURATION PARAMETERS
hostname = "Raspi2-01"

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


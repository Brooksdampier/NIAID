# To create the SWAP file, you will need to use this.
sudo fallocate -l 4G /swapfile	# same as "sudo dd if=/dev/zero of=/swapfile bs=1G count=4"

# Secure swap.
sudo chown root:root /swapfile
sudo chmod 0600 /swapfile

# Prepare the swap file by creating a Linux swap area.
sudo mkswap /swapfile

# Activate the swap file.
sudo swapon /swapfile

# This will last until the server reboots. Let's create the entry in the fstab.
sudo nano /etc/fstab
: /swapfile	none	swap	sw	0 0

# Swappiness in the file should be set to 0. Skipping this step may cause both poor performance,
# whereas setting it to 0 will cause swap to act as an emergency buffer, preventing out-of-memory crashes.
echo 0 | sudo tee /proc/sys/vm/swappiness
echo vm.swappiness = 0 | sudo tee -a /etc/sysctl.conf

echo "# IP Spoofing protection
: net.ipv4.conf.default.rp_filter = 1
: net.ipv4.conf.all.rp_filter = 1
# Block SYN attacks
: net.ipv4.tcp_syncookies = 1
# Controls IP packet forwarding
: net.ipv4.ip_forward = 0
# Ignore ICMP redirects
: net.ipv4.conf.all.accept_redirects = 0
: net.ipv6.conf.all.accept_redirects = 0
: net.ipv4.conf.default.accept_redirects = 0
: net.ipv6.conf.default.accept_redirects = 0
# Ignore send redirects
: net.ipv4.conf.all.send_redirects = 0
: net.ipv4.conf.default.send_redirects = 0
# Disable source packet routing
: net.ipv4.conf.all.accept_source_route = 0
: net.ipv6.conf.all.accept_source_route = 0
: net.ipv4.conf.default.accept_source_route = 0
: net.ipv6.conf.default.accept_source_route = 0
# Log Martians
: net.ipv4.conf.all.log_martians = 1
# Block SYN attacks
: net.ipv4.tcp_max_syn_backlog = 2048
: net.ipv4.tcp_synack_retries = 2
: net.ipv4.tcp_syn_retries = 5
# Log Martians
: net.ipv4.icmp_ignore_bogus_error_responses = 1
# Ignore ICMP broadcast requests
: net.ipv4.icmp_echo_ignore_broadcasts = 1
# Ignore Directed pings
: net.ipv4.icmp_echo_ignore_all = 1
: kernel.exec-shield = 1
: kernel.randomize_va_space = 1
# disable IPv6 if required (IPv6 might caus issues with the Internet connection being slow)
: net.ipv6.conf.all.disable_ipv6 = 1
: net.ipv6.conf.default.disable_ipv6 = 1
: net.ipv6.conf.lo.disable_ipv6 = 1
# Accept Redirects? No, this is not router
: net.ipv4.conf.all.secure_redirects = 0
# Log packets with impossible addresses to kernel log? yes
: net.ipv4.conf.default.secure_redirects = 0

# [IPv6] Number of Router Solicitations to send until assuming no routers are present.
# This is host and not router.
: net.ipv6.conf.default.router_solicitations = 0
# Accept Router Preference in RA?
: net.ipv6.conf.default.accept_ra_rtr_pref = 0
# Learn prefix information in router advertisement.
: net.ipv6.conf.default.accept_ra_pinfo = 0
# Setting controls whether the system will accept Hop Limit settings from a router advertisement.
: net.ipv6.conf.default.accept_ra_defrtr = 0
# Router advertisements can cause the system to assign a global unicast address to an interface.
: net.ipv6.conf.default.autoconf = 0
# How many neighbor solicitations to send out per address?
: net.ipv6.conf.default.dad_transmits = 0
# How many global unicast IPv6 addresses can be assigned to each interface?
: net.ipv6.conf.default.max_addresses = 1

# In rare occasions, it may be beneficial to reboot your server reboot if it runs out of memory.
# This simple solution can avoid you hours of down time. The vm.panic_on_oom=1 line enables panic
# on OOM; the kernel.panic=10 line tells the kernel to reboot ten seconds after panicking.
: vm.panic_on_oom = 1
: kernel.panic = 10" >> /etc/sysctl.conf


# Let's create a 1GB (or what is best for you) filesystem file for the /tmp parition.
sudo fallocate -l 1G /tmpdisk
sudo mkfs.ext4 /tmpdisk
sudo chmod 0600 /tmpdisk

# Mount the new /tmp partition and set the right permissions.
sudo mount -o loop,noexec,nosuid,rw /tmpdisk /tmp
sudo chmod 1777 /tmp

# Set the /tmp in the fstab.
sudo nano /etc/fstab
: /tmpdisk	/tmp	ext4	loop,nosuid,noexec,rw	0 0
sudo mount -o remount /tmp

# Secure /var/tmp.
sudo mv /var/tmp /var/tmpold
sudo ln -s /tmp /var/tmp
sudo cp -prf /var/tmpold/* /tmp/
sudo rm -rf /var/tmpold/

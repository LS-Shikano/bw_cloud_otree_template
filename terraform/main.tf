resource "openstack_networking_secgroup_v2" "main" {
  name        = "${server.name}"
  description = "${server.name} security group"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.main.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_2" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 80
  port_range_max    = 80
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.main.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_3" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 443
  port_range_max    = 443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.main.id}"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9000
  port_range_max    = 9000
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.main.id}"
}


resource "openstack_compute_instance_v2" "main" {
  name            = "${server.name}"
  image_name      = "${server.image}"
  flavor_name       = "${server.flavor}"
  security_groups = ["${openstack_networking_secgroup_v2.main.name}"]
  user_data = <<EOF
#cloud-config

# Set the locale and timezone
locale: en_US.UTF-8
timezone: Europe/Berlin

# Update and upgrade packages
package_update: true
package_upgrade: true
package_reboot_if_required: false

# Manage the /etc/hosts file
manage_etc_hosts: true

# Install required packages
packages:
  - apt-transport-https
  - ca-certificates
  - curl
  - gnupg-agent
  - software-properties-common
  - fail2ban
  - unattended-upgrades

# Add Docker GPG key and repository
runcmd:
  - echo "Creating /etc/apt/keyrings directory" && logger "Keyrings directory created"
  - install -m 0755 -d /etc/apt/keyrings
  - echo "Adding Docker GPG key" && logger "Docker GPG key added"
  - curl -fsSL --insecure https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  - chmod a+r /etc/apt/keyrings/docker.gpg
  - echo "Adding Docker repository" && logger "Docker repository added"
  - echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists and install Docker packages
  - echo "Updating package lists" && logger "Package lists updated"
  - apt-get update && logger "Package update completed"
  - echo "Installing Docker packages" && logger "Docker packages installation started"
  - apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && logger "Docker packages installed"

# Configure fail2ban 
  - echo "Configuring fail2ban" && logger "Fail2ban configured"
  - printf "[sshd]\nenabled = true\nbanaction = iptables-multiport" > /etc/fail2ban/jail.local
  - systemctl enable fail2ban

  # Restart and enable Docker service
  - echo "Restarting Docker service" && logger "Docker service restarted"
  - systemctl restart docker
  - systemctl enable docker

# Configure users
users:
  - default
  - name: ${var.server.user}
    groups: sudo,docker
    sudo: "ALL=(ALL) NOPASSWD:ALL"
    lock_passwd: true
    shell: /bin/bash
    ssh_authorized_keys:
      - ${file(var.ssh_key_path)}

final_message: "The system is ready, after $UPTIME seconds"


EOF

  network {
    name = "public"
  }
}

#####################

# writing data to files for ansible


resource "local_file" "ansible_inventory" {
  content = templatefile("inventory.tmpl",
    {
      ip   = openstack_compute_instance_v2.main.access_ip_v4
      user = var.server.user
    }
  )
  filename = "../ansible/hosts"
}

resource "local_file" "group_vars" {
  content = templatefile("group_vars.tmpl",
    {
      domain = "${openstack_compute_instance_v2.main.id}.fr.bw-cloud-instance.org"
    }
  )
  filename = "../ansible/group_vars/main.yml"
}

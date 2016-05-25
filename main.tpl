provider "openstack" {
  user_name  = "patrick.mans"
  tenant_name = "${var.tenant_name}"
  password  = "${var.password}"
  insecure = true
  auth_url  = "${var.auth_url}"
}

# Template for appl cloud-init bash
resource "template_file" "init_pm" {
    template = "${file("init_appl.tpl")}"
}

resource "openstack_compute_keypair_v2" "pmkeys" {
  name = "SSH keypair for Terraform instances Customer ${var.customer} Environment ${var.environment}"
  region = "${var.region}"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_networking_subnet_v2" "main" {
  name = "front_${var.customer}_${var.environment}"
  region = "${var.region}"
  network_id = "${openstack_networking_network_v2.main.id}"
  cidr = "172.16.10.0/24"
  ip_version = 4
  enable_dhcp = "true"
  dns_nameservers = ["8.8.8.8","8.8.4.4"]
}

resource "openstack_networking_router_v2" "pm_router" {
  name = "terraform_${var.customer}_${var.environment}"
  region = "${var.region}"
  admin_state_up = "true"
  external_gateway = "${var.external_gateway}"
}

resource "openstack_compute_floatingip_v2" "pm_float" {
  depends_on = ["openstack_networking_router_interface_v2.back"]
  region = "${var.region}"
  pool = "${var.pool}"
}

resource "openstack_networking_router_interface_v2" "front" {
  region = "${var.region}"
  router_id = "${openstack_networking_router_v2.prouter.id}"
  subnet_id = "${openstack_networking_subnet_v2.front.id}"
}

resource "openstack_networking_router_interface_v2" "back" {
  region = "${var.region}"
  router_id = "${openstack_networking_router_v2.pm_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.front.id}"
}

resource "openstack_compute_secgroup_v2" "patrick" {
  name = "terraform_${var.customer}_${var.environment}"
  region = "${var.region}"
  description = "Security group for the Terraform instances"
  rule {
    from_port = 1
    to_port = 65535
    ip_protocol = "tcp"
    cidr = "0.0.0.0/0"
  }
  rule {
    from_port = 1
    to_port = 65535
    ip_protocol = "udp"
    cidr = "0.0.0.0/0"
  }
  rule {
    ip_protocol = "icmp"
    from_port = "-1"
    to_port = "-1"
    cidr = "0.0.0.0/0"
  }
}

resource "openstack_compute_instance_v2" "pm_server" {
  name = "pm_server"
  region = "${var.region}"
  image_name = "${var.image_deb}"
  flavor_name = "${var.flavor_appl}"
  key_pair = "${openstack_compute_keypair_v2.pmkeys.name}"
  security_groups = [ "${openstack_compute_secgroup_v2.patrick.name}" ]
  floating_ip = "${openstack_compute_floatingip_v2.pm_float.address}"
  user_data = "${template_file.init_pm.rendered}"
  network {
    uuid = "${openstack_networking_network_v2.main.id}"
    fixed_ip_v4 = "172.16.10.101"
  }
}

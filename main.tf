provider "openstack" {
  user_name  = "patrick.mans"
  tenant_name = "${var.tenant_name}"
  password  = "${var.password}"
  insecure = true
  auth_url  = "${var.auth_url}"
}

provider "aws" {
  region     = "us-east-1"
  shared_credentials_file  = "${var.aws_credentials_file}"
}

# Template for appl cloud-init bash
resource "template_file" "init_pm" {
    template = "${file("init_appl.tpl")}"
}

resource "openstack_compute_keypair_v2" "pmkeys" {
  name = "Keypair ${var.customer}"
  region = "${var.region}"
  public_key = "${file("${var.ssh_key_file}.pub")}"
}

resource "openstack_networking_network_v2" "main" {
  name = "frontend_${var.customer}_${var.environment}"
  region = "${var.region}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "main" {
  name = "front_${var.customer}_${var.environment}"
  region = "${var.region}"
  network_id = "${openstack_networking_network_v2.main.id}"
  cidr = "10.0.10.0/24"
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

resource "openstack_networking_router_interface_v2" "back" {
  region = "${var.region}"
  router_id = "${openstack_networking_router_v2.pm_router.id}"
  subnet_id = "${openstack_networking_subnet_v2.main.id}"
}

resource "openstack_compute_secgroup_v2" "patrick" {
  name = "terraform_${var.customer}_${var.environment}"
  region = "${var.region}"
  description = "SG for Patrick"
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
    fixed_ip_v4 = "10.0.10.100"
  }
}

resource "aws_route53_zone" "primary" {
   name = "${var.domain}"
}

resource "aws_route53_record" "lb" {
   zone_id = "${aws_route53_zone.primary.zone_id}"
   name = "${var.lburl}"
   type = "A"
   ttl = "300"
   records = ["${openstack_compute_floatingip_v2.pm_float.address}"]
}

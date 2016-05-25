output "customer" {
    value = "${var.customer}"
}

output "environment" {
    value = "${var.environment}"
}

output "global IP" {
  value="${openstack_compute_floatingip_v2.pm_float.address}"
}

output "bosh_cidr" {
  value = "${var.bosh_subnet_cidr}"
}
output "bosh_gw" {
  value = "${google_compute_subnetwork.bosh.gateway_address}"
}

output "dns" {
  value = "${var.dns_zone}.${var.dns_name}"
}

output "network_name" {
  value = "${google_compute_network.concourse}"
}

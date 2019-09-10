output "bosh_cidr" {
  value = "${var.bosh_subnet_cidr}"
}
output "bosh_gw" {
  value = "${google_compute_subnetwork.bosh.gateway_address}"
}
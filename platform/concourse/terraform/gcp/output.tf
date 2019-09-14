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
  value = "${google_compute_network.concourse.name}"
}

output "bosh_subnet" {
  value = "${google_compute_subnetwork.bosh.name}"
}

# output "jbx-tags" {
#   value = "value"
# }

output "gcp_json" {
  value = "${var.gcp_creds}"
}

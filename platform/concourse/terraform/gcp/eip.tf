resource "google_compute_address" "jumpbox-ip" {
  name = "jumpbox-concourse-${var.dns_zone}"
}

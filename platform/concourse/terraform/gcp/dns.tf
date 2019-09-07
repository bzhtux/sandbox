data "google_dns_managed_zone" "dns_zone" {
  name = "${var.dns_zone}"
}

resource "google_dns_record_set" "jumpbox" {
  name = "jumpbox.${data.google_dns_managed_zone.dns_zone.dns_name}"
  type = "A"
  ttl  = 60

  managed_zone = "${data.google_dns_managed_zone.dns_zone.name}"

  rrdatas = ["${google_compute_address.jumpbox-ip.address}"]
}

resource "google_dns_record_set" "concourse" {
  name = "concourse.${data.google_dns_managed_zone.dns_zone.dns_name}"
  type = "A"
  ttl  = 60

  managed_zone = "${data.google_dns_managed_zone.dns_zone.name}"

  rrdatas = ["${google_compute_address.concourse_global_ip.address}"]
}
resource "google_compute_network" "concourse" {
  name                    = "${var.network}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "jumpbox" {
  name                     = "${var.jbx_subnet}"
  ip_cidr_range            = "${var.jbx_subnet_cidr}"
  network                  = "${google_compute_network.concourse.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = "${var.internetless}"
}

resource "google_compute_subnetwork" "bosh" {
  name                     = "${var.bosh_subnet}"
  ip_cidr_range            = "${var.bosh_subnet_cidr}"
  network                  = "${google_compute_network.concourse.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = "${var.internetless}"
}

resource "google_compute_subnetwork" "concourse" {
  name                     = "${var.concourse_subnet}"
  ip_cidr_range            = "${var.concourse_subnet_cidr}"
  network                  = "${google_compute_network.concourse.self_link}"
  region                   = "${var.region}"
  private_ip_google_access = "${var.internetless}"
}

resource "google_compute_router" "nat-router" {
  name    = "nat-router"
  region  = "${var.region}"
  network = "${google_compute_network.concourse.self_link}"

  bgp {
    asn = 64514
  }
}

resource "google_compute_address" "nat-address" {
  name   = "concourse-nat-addr"
  region = "${var.region}"
}

resource "google_compute_router_nat" "advanced-nat" {
  name                               = "nat-1"
  router                             = "${google_compute_router.nat-router.name}"
  region                             = "${var.region}"
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = ["${google_compute_address.nat-address.self_link}"]
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

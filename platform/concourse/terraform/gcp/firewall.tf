resource "google_compute_firewall" "jbx-ssh" {
  name  = "jbx-ssh"
  network   = "${google_compute_subnetwork.jumpbox}"

  allow {
      protocol  = "tcp"
      ports     = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "jbx-ssh" {
  name          = "jbx-ssh"
  network       = "${google_compute_network.concourse.name}"
  target_tags   = ["jbx-ssh"]
  priority      = 900

allow {
    protocol    = "icmp"
}

  allow {
    protocol    = "tcp"
    ports       = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}


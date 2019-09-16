resource "google_compute_firewall" "ssh" {
  name          = "jbx-ssh"
  network       = "${google_compute_network.concourse.name}"
  target_tags   = ["ssh"]
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

resource "google_compute_firewall" "bosh-agent" {
  name          = "bosh-agent"
  network       = "${google_compute_network.concourse.name}"
  target_tags   = ["bosh-agent"]
  priority      = 900

allow {
  protocol    = "icmp"
}

allow {
  protocol    = "tcp"
  ports       = ["6868","25555","8443"]
}

source_ranges = ["0.0.0.0/0"]
}

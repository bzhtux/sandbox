resource "google_compute_instance" "jumpbox" {
  name          = "jbx"
  machine_type  = "${var.jbx_machine_type}"
  zone          = "${var.region}-c"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1604-lts"
      size  = "50"
      type  = "pd-ssd"
    }
  }

  scratch_disk {
  }

  network_interface {
    subnetwork   = "${var.jbx_subnet}"
    access_config {
        nat_ip = "${google_compute_address.jumpbox-ip.address}"
    }
  }

  metadata {
      sshKeys   = "${var.ssh_pub_key}"
  }

  tags  = ["ssh"]
}

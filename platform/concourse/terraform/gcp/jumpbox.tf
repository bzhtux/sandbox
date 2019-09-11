resource "google_compute_project_metadata_item" "ssh-keys" {
  key   = "ssh-keys"
  value = "${var.ssh_pub_key}"
}
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

#   scratch_disk {}

  network_interface {
    subnetwork   = "${google_compute_subnetwork.jumpbox.name}"
    access_config {
      nat_ip = "${google_compute_address.jumpbox-ip.address}"
    }
  }

  metadata = {
    sshKeys = "${var.ssh_user}:${var.ssh_pub_key}"
  }

  tags  = ["jbx-ssh"]

  service_account {
    scopes = ["compute-ro", "storage-ro"]
  }

  provisioner "file" {
    source      = "../../../bosh/scripts/deploy.sh"
    destination = "~/deploy.sh"
  }
}

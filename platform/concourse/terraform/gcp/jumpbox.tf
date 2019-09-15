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

  tags  = ["ssh"]

  service_account {
    scopes = ["compute-ro", "storage-ro"]
  }

  # provisioner "file" {
  #   connection {
  #     type        = "ssh"
  #     host        = "${google_compute_address.jumpbox-ip.address}"
  #     user        = "${var.ssh_user}"
  #     private_key = "${var.ssh_priv_key}"
  #     agent       = false
  #   }
  #   source      = "../../../bosh/scripts/deploy.sh"
  #   destination = "~/deploy.sh"
  # }

  # provisioner "remote-exec" {
  #   connection {
  #     type        = "ssh"
  #     host        = "${google_compute_address.jumpbox-ip.address}"
  #     user        = "${var.ssh_user}"
  #     private_key = "${var.ssh_priv_key}"
  #     agent       = false
  #   }
  #   inline = [
  #     "chmod +x deploy.sh"
  #   ]
  # }

  # provisioner "remote-exec" {
  #   connection {
  #     type        = "ssh"
  #     host        = "${google_compute_address.jumpbox-ip.address}"
  #     user        = "${var.ssh_user}"
  #     private_key = "${var.ssh_priv_key}"
  #     agent       = false
  #   }
  #   inline = [
  #     "sudo apt update",
  #     "sudo apt install -y jq git curl"
  #   ]
  # }

}

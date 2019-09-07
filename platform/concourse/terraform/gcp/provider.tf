provider "google" {
  credentials = "${file("/Users/yfoeillet/Documents/workdir/creds/gcp/terraform/cso-pcfs-emea-bzhtux-terraform-service-account.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.region}-c"

  version = ">= 1.7.0"
}

terraform {
  required_version = ">= 0.12.0"
}

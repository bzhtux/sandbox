provider "google" {
  credentials = "${var.gcp_creds}"
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.region}-c"

  # version = ">= 1.7.0"
}

terraform {
  # required_version = ">= 0.12.0"
  backend "gcs" {
  bucket  = "bzhtux-tf-state"
  prefix  = "concourse/gcp/terraform.tfstate"
  credentials = "/Users/yfoeillet/workdir/creds/gcp/terraform/cso-pcfs-emea-bzhtux-terraform-service-account.json"
  }
}

provider "google" {
  credentials = "${var.gcp_creds}"
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.region}-c"

  version = ">= 1.7.0"
}

terraform {
  required_version = ">= 0.12.0"
}

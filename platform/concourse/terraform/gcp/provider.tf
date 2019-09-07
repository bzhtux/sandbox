provider "google" {
  credentials = "${file("$HOME/gcp-creds/service-account-1567884587.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
  zone        = "${var.region}-c"

  version = ">= 1.7.0"
}

terraform {
  required_version = ">= 0.12.0"
}

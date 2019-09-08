variable "project" {
  type    = "string"
  default = "cso-pcfs-emea-bzhtux"
}

variable "gcp_creds" {
  type    = "string"
}

variable "source_env" {
  type    = "map"
}


variable "region" {
  type    = "string"
  default = "europe-west1"
}

variable "network" {
  type    = "string"
  default = "concourse"
}


variable "jbx_subnet" {
  type    = "string"
  default = "jbx"
}

variable "jbx_subnet_cidr" {
  type    = "string"
  default = "10.0.30.0/24"
}
variable "bosh_subnet" {
  type    = "string"
  default = "bosh"
}

variable "bosh_subnet_cidr" {
  type    = "string"
  default = "10.0.10.0/24"
}

variable "concourse_subnet" {
  type    = "string"
  default = "concourse"
}

variable "concourse_subnet_cidr" {
  type    = "string"
  default = "10.0.20.0/24"
}

variable "internetless" {
  description = "When set to true, all traffic going outside the 10.* network is denied."
  default     = false
}

variable "dns_zone" {
  type    = "string"
  default = "pivotal"
}

variable "dns_name" {
  type    = "string"
  default = "bzhtux-lab.net."
}

variable "jbx_machine_type" {
  type    = "string"
  default = "n1-standard-1"
}

variable "ssh_pub_key" {
  type    = "string"
}

variable "project" {}

provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.project}"
  region      = "us-central1"
  zone        = "us-central1-c"
}

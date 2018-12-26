variable "project" {}

provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.project}"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_kms_key_ring" "my_key_ring" {
  name     = "image-processor-key-ring"
  project  = "${var.project}"
  location = "us-central1"
}

resource "google_kms_crypto_key" "my_crypto_key" {
  name            = "image-processor-crypto-key"
  key_ring        = "${google_kms_key_ring.my_key_ring.self_link}"
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_network" "vpc_network" {
  name                    = "image-processor"
  auto_create_subnetworks = "true"
}

resource "google_compute_firewall" "web-firewall" {
  name    = "web-firewall"
  network = "${google_compute_network.vpc_network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}

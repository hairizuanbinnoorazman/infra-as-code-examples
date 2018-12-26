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

  #   lifecycle {
  #     prevent_destroy = true
  #   }
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

resource "google_storage_bucket" "image-store" {
  name          = "${var.project}-image-processor-store"
  location      = "US"
  storage_class = "MULTI_REGIONAL"
}

resource "google_pubsub_topic" "website-screenshot-request" {
  name = "website-screenshot-request"
}

resource "google_pubsub_subscription" "website-worker" {
  name  = "default-subscription"
  topic = "${google_pubsub_topic.website-screenshot-request.name}"

  ack_deadline_seconds = 30
}

resource "google_sourcerepo_repository" "ansible-scripts-repo" {
  name = "ansible-scripts"
}

resource "google_sourcerepo_repository" "web-api-repo" {
  name = "web-api"
}

resource "google_sourcerepo_repository" "screenshot-task-repo" {
  name = "screenshot-task"
}

resource "google_cloudbuild_trigger" "web-api-build-trigger" {
  project = "${var.project}"

  trigger_template {
    branch_name = "master"
    project     = "${var.project}"
    repo_name   = "${google_sourcerepo_repository.web-api-repo.name}"
  }

  filename = "cloudbuild.yaml"
}

resource "google_cloudbuild_trigger" "screenshot-task-repo" {
  project = "${var.project}"

  trigger_template {
    branch_name = "master"
    project     = "${var.project}"
    repo_name   = "${google_sourcerepo_repository.screenshot-task-repo.name}"
  }

  filename = "cloudbuild.yaml"
}

resource "google_sql_database_instance" "master" {
  name             = "master-instance"
  database_version = "POSTGRES_9_6"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"
  }
}

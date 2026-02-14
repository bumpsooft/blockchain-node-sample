provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_compute_network" "vpc" {
  name = var.network_name
}

data "google_compute_subnetwork" "subnet" {
  name   = var.subnetwork_name
  region = var.region
}

data "google_compute_zones" "available" {
  region = var.region
}

resource "google_compute_address" "gnosis_node_ip" {
  name   = "${var.gnosis_node_name}-ip"
  region = var.region
}

resource "google_compute_address" "gnosis_node_internal_ip" {
  name         = "${var.gnosis_node_name}-internal-ip"
  subnetwork   = data.google_compute_subnetwork.subnet.id
  address_type = "INTERNAL"
  region       = var.region
}

resource "google_compute_instance" "gnosis-node" {
  name         = var.gnosis_node_name
  machine_type = "e2-standard-4"
  zone         = data.google_compute_zones.available.names[0]
  tags         = ["gnosis-node"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-13"
      size  = 1000
      type  = "pd-ssd"
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.subnet.id
    network_ip = google_compute_address.gnosis_node_internal_ip.address
    access_config {
      nat_ip = google_compute_address.gnosis_node_ip.address
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}

resource "google_compute_firewall" "gnosis_node_rules" {
  name    = "gnosis-node-firewall"
  network = data.google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["30303", "9000"]
  }

  allow {
    protocol = "udp"
    ports    = ["30303", "9000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["gnosis-node"]
}

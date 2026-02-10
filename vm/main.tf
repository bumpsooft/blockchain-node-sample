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

resource "google_compute_instance" "node_vm" {
  name         = var.vm_name
  machine_type = "e2-custom-${var.vm_vcpu}-${var.vm_memory_mb}"
  zone         = data.google_compute_zones.available.names[0]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-13"
      size  = var.vm_disk_size_gb
      type  = var.vm_disk_type
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.subnet.id
    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}

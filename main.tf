provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_compute_zones" "available" {
  region = var.region
}

resource "google_compute_network" "vpc" {
  name                    = "rpi-vpn-test-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "rpi-vpn-subnet"
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_firewall" "allow_internal" {
  name    = "allow-vpn-internal"
  network = google_compute_network.vpc.name

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  source_ranges = ["10.10.0.0/24", var.home_internal_cidr]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-from-my-ip"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["vpn-test-vm"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_vpn_gateway" "target_gateway" {
  name    = "rpi-vpn-gateway"
  network = google_compute_network.vpc.id
  region  = var.region
}

resource "google_compute_address" "vpn_static_ip" {
  name   = "vpn-static-ip"
  region = var.region
}

resource "google_compute_vpn_tunnel" "tunnel" {
  name               = "rpi-vpn-tunnel"
  peer_ip            = var.home_public_ip
  shared_secret      = var.vpn_psk
  target_vpn_gateway = google_compute_vpn_gateway.target_gateway.id

  local_traffic_selector  = ["10.10.0.0/24"]
  remote_traffic_selector = [var.home_internal_cidr]

  depends_on = [
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_ip.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_route" "route_to_home" {
  name                = "route-to-home"
  network             = google_compute_network.vpc.name
  dest_range          = var.home_internal_cidr
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel.id
}

resource "google_compute_instance" "test_vm" {
  name         = "vpn-test-vm"
  machine_type = "e2-micro"
  zone         = data.google_compute_zones.available.names[0]
  tags         = ["vpn-test-vm"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }
}
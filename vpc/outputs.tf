output "network_name" {
  value = google_compute_network.vpc.name
}

output "subnetwork_name" {
  value = google_compute_subnetwork.subnet.name
}

output "gcp_vpn_ip" {
  value = google_compute_address.vpn_static_ip.address
}

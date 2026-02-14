output "vm_public_ip" {
  value = google_compute_instance.gnosis-node.network_interface.0.access_config.0.nat_ip
}

output "vm_private_ip" {
  value = google_compute_instance.gnosis-node.network_interface.0.network_ip
}

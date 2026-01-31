output "gcp_vpn_ip" {
  value = google_compute_address.vpn_static_ip.address
}
output "vm_public_ip" {
  value = google_compute_instance.test_vm.network_interface.0.access_config.0.nat_ip
}
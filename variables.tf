variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  default = "asia-northeast3"
}

variable "home_public_ip" {
  description = "Public IP of the home router"
  type        = string
}

variable "home_internal_cidr" {
  description = "Home internal network CIDR (e.g., 192.168.0.0/24)"
  type        = string
  default     = "192.168.0.0/24"
}

variable "vpn_psk" {
  description = "VPN Pre-Shared Key"
  type        = string
  sensitive   = true
}

variable "ssh_user" {
  description = "SSH Username"
  type        = string
  default     = "bumpsoo"
}

variable "ssh_public_key" {
  description = "SSH Public Key content"
  type        = string
}
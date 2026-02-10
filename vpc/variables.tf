variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  default = "asia-northeast3"
}

variable "personal_public_ip" {
  description = "Public IP of the personal network"
  type        = string
}

variable "personal_internal_cidr" {
  description = "Personal network CIDR (e.g., 192.168.0.0/24)"
  type        = string
  default     = "192.168.0.0/24"
}

variable "vpn_psk" {
  description = "VPN Pre-Shared Key"
  type        = string
  sensitive   = true
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "vpn-personal-vpc"
}

variable "subnet_name" {
  description = "Name of the subnetwork"
  type        = string
  default     = "vpn-personal-subnet"
}

variable "vpn_gateway_name" {
  description = "Name of the VPN gateway"
  type        = string
  default     = "vpn-personal-gateway"
}

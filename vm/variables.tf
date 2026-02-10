variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  default = "asia-northeast3"
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

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnetwork_name" {
  description = "Name of the subnetwork"
  type        = string
}

variable "vm_name" {
  description = "Name of the VM instance"
  type        = string
  default     = "vpn-personal-vm"
}

variable "vm_vcpu" {
  description = "Number of vCPUs for the VM (must be even number >= 2)"
  type        = number
  default     = 2
}

variable "vm_memory_mb" {
  description = "Amount of memory in MB for the VM (must be multiple of 256)"
  type        = number
  default     = 4096
}

variable "vm_disk_size_gb" {
  description = "Size of the VM boot disk in GB"
  type        = number
  default     = 20
}

variable "vm_disk_type" {
  description = "Type of the VM boot disk (e.g., pd-standard, pd-balanced, pd-ssd)"
  type        = string
  default     = "pd-balanced"
}

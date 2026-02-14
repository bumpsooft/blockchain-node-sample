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

variable "gnosis_node_name" {
  description = "Name of the gnosis node"
  type        = string
  default     = "gnosis-node"
}

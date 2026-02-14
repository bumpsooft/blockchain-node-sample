# GCP Blockchain Node Sample Infrastructure

This project provides a Terraform (OpenTofu) configuration to set up a secure infrastructure on Google Cloud Platform suitable for running blockchain nodes. It establishes a dedicated VPC with a Site-to-Site VPN connection and provisions a customizable compute instance.

## Project Structure

* vpc/: Contains networking resources including VPC, subnets, firewall rules, and VPN gateway.
* vm/: Contains the compute instance configuration with customizable hardware specs (vCPU, RAM, Disk).

## Prerequisites

* Google Cloud Platform account and project
* OpenTofu (or Terraform) installed
* gcloud CLI installed and authenticated

## Usage

### 1. Network Setup (VPC)

Navigate to the vpc directory and configure your variables in terraform.tfvars.

```hcl
project_id             = "your-project-id"
region                 = "us-central1"
personal_public_ip     = "x.x.x.x"          # Your local network public IP
personal_internal_cidr = "192.168.x.0/24"   # Your local network CIDR
vpn_psk                = "your-secret-key"
```

Initialize and apply the configuration:

```bash
cd vpc
tofu init
tofu apply
```

This will output the public IP of the GCP VPN Gateway (gcp_vpn_ip). Use this IP to configure your local VPN endpoint.

### 2. Node Setup (Gnosis Node)

Navigate to the vm directory and configure your variables in terraform.tfvars.

```hcl
project_id       = "your-project-id"
region           = "asia-northeast3"
ssh_public_key   = "ssh-ed25519 ..."
network_name     = "blockchain-vpc"    # Must match the VPC created above
subnetwork_name  = "blockchain-subnet" # Must match the Subnet created above

gnosis_node_name = "gnosis-node"
```

The configuration is now optimized for a Gnosis node with:
- **Machine Type**: e2-standard-4 (4 vCPU, 16 GB RAM)
- **Storage**: 1000 GB PD-SSD
- **Firewall**: Ports 30303 (TCP/UDP) and 9000 (TCP/UDP) are exposed for P2P networking and discovery.

Initialize and apply the configuration:

```bash
cd vm
tofu init
tofu apply
```

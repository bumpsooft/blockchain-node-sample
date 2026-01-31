
# GCP to Local Home Network VPN Setup

This project uses OpenTofu (or Terraform) to configure a VPC and VPN on Google Cloud Platform (GCP), establishing a Site-to-Site VPN connection with a home server (e.g., Raspberry Pi).

## Architecture Overview

- **GCP Side**:
  - **VPC Network**: `rpi-vpn-test-vpc`
  - **Subnet**: `rpi-vpn-subnet` (`10.10.0.0/24`)
  - **VPN Gateway**: Classic VPN Gateway
  - **Firewall Rules**:
    - Allow VPN and internal traffic (ICMP, TCP, UDP)
    - Allow SSH access (for test VM)
  - **Compute Engine**: `vpn-test-vm` (e2-micro instance for connection testing)

- **Local Side (User Environment)**:
  - Raspberry Pi (or home server) behind a router running a VPN daemon (e.g., StrongSwan, Libreswan)
  - Port Forwarding required: UDP `500`, `4500` -> Raspberry Pi internal IP

## Prerequisites

1. **GCP Account & Project**: A billing-enabled GCP project is required.
2. **OpenTofu/Terraform Installed**: Refer to the [OpenTofu Installation Guide](https://opentofu.org/docs/intro/install/).
3. **GCP Authentication**: Authenticate locally via terminal.
   ```bash
   gcloud auth application-default login
   ```
4. **Check Home Public IP**: Identify your current public IP address.

## Usage

### 1. Configure Variables (`terraform.tfvars`)

Create a `terraform.tfvars` file in the project root and configure it according to your environment.

```hcl
project_id         = "YOUR_GCP_PROJECT_ID"
home_public_ip     = "123.123.123.123"
vpn_psk            = "your-secret-password"
home_internal_cidr = "192.168.0.0/24"
ssh_public_key     = "ssh-rsa AAA..."
```

### 2. Initialize and Apply

```bash
# Initialize
tofu init

# Plan
tofu plan

# Apply
tofu apply
```

### 3. Check Results

Upon completion of `tofu apply`, the following information will be output:

- `gcp_vpn_ip`: The public IP of the GCP VPN Gateway (target for Raspberry Pi connection).
- `vm_public_ip`: The public IP of the test VM.

## Raspberry Pi Configuration Guide (StrongSwan with swanctl)

This guide uses the modern `swanctl` (VICI protocol) provided by StrongSwan 6.x+.

1. **Install StrongSwan and Plugins**:
   ```bash
   sudo apt-get update
   sudo apt-get install -y strongswan libcharon-extra-plugins libstrongswan-extra-plugins libstrongswan-standard-plugins strongswan-pki
   ```

2. **Configure `/etc/swanctl/swanctl.conf`**:
   Replace the content of `/etc/swanctl/swanctl.conf` with the following configuration.
   
   > **Note**: Replace `YOUR_HOME_PUBLIC_IP`, `GCP_VPN_IP`, `YOUR_PSK`, and `HOME_CIDR` with your actual values.

   ```conf
   connections {
      gcp-vpn {
         remote_addrs = GCP_VPN_IP
         
         local {
            auth = psk
            id = YOUR_HOME_PUBLIC_IP
         }
         
         remote {
            auth = psk
            id = GCP_VPN_IP
         }
         
         children {
            gcp-net {
               local_ts = 192.168.0.0/24   # Your Home Network CIDR (e.g., 192.168.2.0/24)
               remote_ts = 10.10.0.0/24    # GCP Network CIDR
               
               esp_proposals = aes256-sha1-modp2048
               start_action = start
            }
         }
         
         version = 2
         proposals = aes256-sha1-modp2048
      }
   }

   secrets {
      ike-gcp {
         id = GCP_VPN_IP
         secret = "YOUR_PSK"
      }
   }
   ```

3. **Apply & Start**:
   ```bash
   # Load configuration
   sudo swanctl --load-all
   
   # Check status (should show ESTABLISHED)
   sudo swanctl --list-sas
   ```

4. **Enable IP Forwarding**:
   For the Raspberry Pi to act as a gateway and forward traffic to other devices, you must enable packet forwarding.
   
   Edit `/etc/sysctl.conf` and uncomment (or add) the following line:
   ```conf
   net.ipv4.ip_forward=1
   ```
   
   Apply changes:
   ```bash
   sudo sysctl -p
   ```

- **Important**: Ensure UDP `500` and `4500` ports are port-forwarded to the Raspberry Pi's internal IP in your router settings.
- **Routing Setup (Home Router)**: You must configure a **Static Route** on your home router so that other devices in your home network can reach the GCP network.
   - **Destination Network**: `10.10.0.0`
   - **Subnet Mask**: `255.255.255.0` (or `/24`)
   - **Gateway**: The internal IP of your Raspberry Pi (e.g., `192.168.2.x`)
   
   Without this, only the Raspberry Pi itself can access the GCP network. Other devices (like your PC) won't know that traffic for `10.10.0.x` should go through the Raspberry Pi.

## Connection Test

1. Verify the tunnel status is "Established" in the [VPN](https://console.cloud.google.com/hybrid/vpn/gateways) menu of the GCP Console.
2. SSH into the test VM (`vpn-test-vm`).
3. Ping a device in the home internal network (e.g., Raspberry Pi).
   ```bash
   ping 192.168.0.x
   ```

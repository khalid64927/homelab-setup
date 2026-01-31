# WireGuard VPN Setup

Secure VPN access to your home network from anywhere in the world.

## Features

- 🔐 Modern, fast VPN protocol
- 📱 Easy mobile setup via QR code
- 🚀 Automated configuration
- 👥 Multi-client support
- 🔧 Works with most routers

## Prerequisites

### Router Configuration (REQUIRED)

Before running the setup script, configure port forwarding on your router:

1. Log into your router's admin panel
2. Find **Port Forwarding** / **Virtual Server** / **NAT** settings
3. Add this rule:
   - **Service:** WireGuard
   - **Protocol:** UDP
   - **External Port:** 51820
   - **Internal IP:** Your server's IP (e.g., 192.168.0.10)
   - **Internal Port:** 51820
4. Save and apply

### Server Requirements

- Ubuntu 20.04+
- Static local IP address
- Sudo access

## Installation
```bash
cd scripts/wireguard
chmod +x setup.sh
sudo ./setup.sh
```

## Adding Clients

To add additional devices:
```bash
sudo ./add-client.sh laptop
sudo ./add-client.sh tablet
```

## Mobile Setup

### iOS
1. Install WireGuard from App Store
2. Scan QR code shown after setup
3. Toggle connection ON

### Android
1. Install WireGuard from Play Store
2. Scan QR code shown after setup
3. Toggle connection ON

## Usage

Once connected to VPN, access your services:
- Immich: `http://192.168.0.10:2283`
- Jellyfin: `http://192.168.0.10:8096`
- Any other local service

## Management

**Check status:**
```bash
sudo wg show
```

**Restart VPN:**
```bash
sudo systemctl restart wg-quick@wg0
```

**View logs:**
```bash
sudo journalctl -u wg-quick@wg0 -f
```

## Troubleshooting

### Can't connect
1. Verify port forwarding is configured
2. Check public IP: `curl ifconfig.me`
3. Verify WireGuard is running: `sudo wg show`

### Connected but can't access services
1. Check server IP hasn't changed
2. Verify services are running
3. Check firewall rules

### Connection drops
- ISP might block VPN
- Try different port
- Check if public IP changed

## Security

- Private keys stored in `/etc/wireguard/`
- Config files in user home directory
- Never commit keys to version control
- Rotate keys periodically

## Files

- `setup.sh` - Main installation script
- `add-client.sh` - Add new clients
- `README.md` - This file

## Port Information

- **WireGuard:** UDP 51820
- **Access:** All home network services

---

[Back to main README](../../README.md)

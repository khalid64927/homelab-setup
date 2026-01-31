#!/bin/bash
# WireGuard VPN Setup Script
# Part of homelab-setup monorepo

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"

print_header "WireGuard VPN Setup"

# Check if running as root
check_root

# Get user info
ACTUAL_USER=$(get_actual_user)
USER_HOME=$(get_user_home)

print_step "Installing WireGuard and dependencies"
apt update
apt install -y wireguard qrencode iptables

print_step "Detecting network configuration"
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
print_info "Detected interface: $INTERFACE"

print_step "Getting public IP"
PUBLIC_IP=$(curl -s ifconfig.me)
print_info "Your public IP: $PUBLIC_IP"

echo ""
read -p "Is this your correct public IP? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    read -p "Enter your public IP address: " PUBLIC_IP
fi

read -p "Enter your server's LOCAL IP address (e.g., 192.168.0.10): " LOCAL_IP

print_step "Generating server keys"
cd /etc/wireguard

if [ ! -f server_private.key ]; then
    wg genkey | tee server_private.key | wg pubkey > server_public.key
    chmod 600 server_private.key
    chmod 644 server_public.key
    print_success "Server keys generated"
else
    print_info "Using existing server keys"
fi

SERVER_PRIVATE_KEY=$(cat server_private.key)
SERVER_PUBLIC_KEY=$(cat server_public.key)

print_step "Generating client keys"
cd "$USER_HOME"

if [ ! -f wireguard_client1_private.key ]; then
    wg genkey | tee wireguard_client1_private.key | wg pubkey > wireguard_client1_public.key
    chown $ACTUAL_USER:$ACTUAL_USER wireguard_client1_private.key wireguard_client1_public.key
    print_success "Client keys generated"
else
    print_info "Using existing client keys"
fi

CLIENT_PRIVATE_KEY=$(cat wireguard_client1_private.key)
CLIENT_PUBLIC_KEY=$(cat wireguard_client1_public.key)

print_step "Creating WireGuard server configuration"
cat > /etc/wireguard/wg0.conf << WGEOF
[Interface]
PrivateKey = $SERVER_PRIVATE_KEY
Address = 10.0.0.1/24
ListenPort = 51820
SaveConfig = true

PostUp = sysctl -w net.ipv4.ip_forward=1
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT
PostUp = iptables -A FORWARD -o wg0 -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -o $INTERFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT
PostDown = iptables -D FORWARD -o wg0 -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -o $INTERFACE -j MASQUERADE

[Peer]
# Mobile Client 1
PublicKey = $CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/32
WGEOF

chmod 600 /etc/wireguard/wg0.conf

print_step "Enabling IP forwarding"
if ! grep -q "^net.ipv4.ip_forward=1" /etc/sysctl.conf; then
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
fi
sysctl -p > /dev/null

print_step "Creating client configuration"
cat > "$USER_HOME/wireguard_client1.conf" << CLIENTEOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = 10.0.0.2/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $PUBLIC_IP:51820
AllowedIPs = 10.0.0.0/24, 192.168.0.0/24
PersistentKeepalive = 25
CLIENTEOF

chown $ACTUAL_USER:$ACTUAL_USER "$USER_HOME/wireguard_client1.conf"

print_step "Starting WireGuard service"
systemctl stop wg-quick@wg0 2>/dev/null || true
systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

print_success "WireGuard VPN Setup Complete!"

echo ""
print_header "Configuration Summary"
echo "Server Public Key: $SERVER_PUBLIC_KEY"
echo "Server Local IP: $LOCAL_IP"
echo "Network Interface: $INTERFACE"
echo "Public IP: $PUBLIC_IP"
echo "WireGuard Port: 51820 (UDP)"
echo ""
print_header "Mobile Client Setup"
echo "1. Install WireGuard app from App Store / Play Store"
echo "2. Scan this QR code:"
echo ""

qrencode -t ansiutf8 < "$USER_HOME/wireguard_client1.conf"

echo ""
echo "Config file: $USER_HOME/wireguard_client1.conf"
echo ""
print_header "Router Configuration Required"
echo "Forward UDP port 51820 to $LOCAL_IP:51820"
echo ""
print_info "Add more clients: $SCRIPT_DIR/add-client.sh <name>"
print_info "Check status: sudo wg show"

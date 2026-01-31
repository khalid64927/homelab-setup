#!/bin/bash
# Add additional WireGuard clients

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/functions.sh"

check_root

if [ -z "$1" ]; then
    print_error "Usage: sudo ./add-client.sh <client_name>"
    echo "Example: sudo ./add-client.sh laptop"
    exit 1
fi

CLIENT_NAME=$1
ACTUAL_USER=$(get_actual_user)
USER_HOME=$(get_user_home)

# Find next available IP
NEXT_IP=2
while wg show wg0 2>/dev/null | grep -q "10.0.0.$NEXT_IP"; do
    ((NEXT_IP++))
done

print_header "Adding WireGuard Client: $CLIENT_NAME"
print_info "Assigning IP: 10.0.0.$NEXT_IP"

cd "$USER_HOME"

# Generate client keys
wg genkey | tee wireguard_${CLIENT_NAME}_private.key | wg pubkey > wireguard_${CLIENT_NAME}_public.key
chown $ACTUAL_USER:$ACTUAL_USER wireguard_${CLIENT_NAME}_private.key wireguard_${CLIENT_NAME}_public.key

CLIENT_PRIVATE_KEY=$(cat wireguard_${CLIENT_NAME}_private.key)
CLIENT_PUBLIC_KEY=$(cat wireguard_${CLIENT_NAME}_public.key)
SERVER_PUBLIC_KEY=$(cat /etc/wireguard/server_public.key)
PUBLIC_IP=$(get_public_ip)

# Add peer to server
wg set wg0 peer $CLIENT_PUBLIC_KEY allowed-ips 10.0.0.$NEXT_IP/32

# Make it persistent
echo "" >> /etc/wireguard/wg0.conf
echo "[Peer]" >> /etc/wireguard/wg0.conf
echo "# $CLIENT_NAME" >> /etc/wireguard/wg0.conf
echo "PublicKey = $CLIENT_PUBLIC_KEY" >> /etc/wireguard/wg0.conf
echo "AllowedIPs = 10.0.0.$NEXT_IP/32" >> /etc/wireguard/wg0.conf

# Create client config
cat > "$USER_HOME/wireguard_${CLIENT_NAME}.conf" << CLIENTEOF
[Interface]
PrivateKey = $CLIENT_PRIVATE_KEY
Address = 10.0.0.$NEXT_IP/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $PUBLIC_IP:51820
AllowedIPs = 10.0.0.0/24, 192.168.0.0/24
PersistentKeepalive = 25
CLIENTEOF

chown $ACTUAL_USER:$ACTUAL_USER "$USER_HOME/wireguard_${CLIENT_NAME}.conf"

print_success "Client '$CLIENT_NAME' added successfully!"
echo ""
print_header "QR Code for Mobile Setup"
qrencode -t ansiutf8 < "$USER_HOME/wireguard_${CLIENT_NAME}.conf"
echo ""
print_info "Config saved to: $USER_HOME/wireguard_${CLIENT_NAME}.conf"

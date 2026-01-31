#!/bin/bash
# Homelab Master Setup Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/scripts/common/functions.sh"

print_header "Homelab Setup - Master Installer"

check_root
check_internet

echo "This script will help you set up your homelab services."
echo ""
echo "Available services:"
echo "  1. WireGuard VPN (Recommended first)"
echo "  2. Immich (Photo backup)"
echo "  3. Jellyfin (Media server)"
echo "  4. Samba (File sharing)"
echo "  5. VNC (Remote desktop)"
echo "  6. Install all"
echo "  7. Exit"
echo ""

read -p "Enter your choice (1-7): " choice

case $choice in
    1)
        print_header "Installing WireGuard VPN"
        cd "$SCRIPT_DIR/scripts/wireguard"
        chmod +x setup.sh
        ./setup.sh
        ;;
    2)
        print_header "Installing Immich"
        print_warning "Immich setup script not yet created"
        print_info "Coming soon!"
        ;;
    3)
        print_header "Installing Jellyfin"
        print_warning "Jellyfin setup script not yet created"
        print_info "Coming soon!"
        ;;
    4)
        print_header "Installing Samba"
        print_warning "Samba setup script not yet created"
        print_info "Coming soon!"
        ;;
    5)
        print_header "Installing VNC"
        print_warning "VNC setup script not yet created"
        print_info "Coming soon!"
        ;;
    6)
        print_header "Installing All Services"
        confirm "This will install all services. Continue?" || exit 0
        # Install in recommended order
        cd "$SCRIPT_DIR/scripts/wireguard" && chmod +x setup.sh && ./setup.sh
        # Add others as they're created
        ;;
    7)
        print_info "Exiting..."
        exit 0
        ;;
    *)
        print_error "Invalid choice"
        exit 1
        ;;
esac

print_success "Setup complete!"

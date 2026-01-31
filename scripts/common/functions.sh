#!/bin/bash
# Common functions for homelab setup scripts

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Print colored output
print_header() {
    echo -e "\n${CYAN}=================================="
    echo -e "$1"
    echo -e "==================================${NC}\n"
}

print_step() {
    echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        print_error "Please run as root (use sudo)"
        exit 1
    fi
}

# Get actual user (not root when using sudo)
get_actual_user() {
    local user=$(logname 2>/dev/null || echo $SUDO_USER)
    if [ -z "$user" ]; then
        user="root"
    fi
    echo "$user"
}

# Get user's home directory
get_user_home() {
    local user=$(get_actual_user)
    eval echo ~$user
}

# Check if service is running
is_service_running() {
    systemctl is-active --quiet "$1"
}

# Check if package is installed
is_package_installed() {
    dpkg -l | grep -q "^ii  $1 "
}

# Confirm action
confirm() {
    local message="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    read -p "$message $prompt: " response
    response=${response:-$default}
    
    [[ "$response" =~ ^[Yy]$ ]]
}

# Create directory if it doesn't exist
ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        print_success "Created directory: $1"
    fi
}

# Backup file
backup_file() {
    if [ -f "$1" ]; then
        cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
        print_success "Backed up: $1"
    fi
}

# Check internet connectivity
check_internet() {
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        print_error "No internet connection"
        return 1
    fi
    return 0
}

# Get local IP address
get_local_ip() {
    ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -n1
}

# Get public IP address
get_public_ip() {
    curl -s ifconfig.me || curl -s icanhazip.com || echo "Unable to detect"
}

# Wait for service to be ready
wait_for_service() {
    local service="$1"
    local max_wait="${2:-30}"
    local count=0
    
    print_step "Waiting for $service to be ready..."
    
    while [ $count -lt $max_wait ]; do
        if is_service_running "$service"; then
            print_success "$service is ready"
            return 0
        fi
        sleep 1
        ((count++))
    done
    
    print_error "$service failed to start within ${max_wait}s"
    return 1
}

# Create systemd service
create_systemd_service() {
    local service_name="$1"
    local service_content="$2"
    
    echo "$service_content" > "/etc/systemd/system/${service_name}.service"
    systemctl daemon-reload
    print_success "Created systemd service: $service_name"
}

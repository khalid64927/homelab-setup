# Homelab Setup Scripts

Complete automation scripts for setting up a home media server with remote access capabilities.

## 🚀 Features

- **WireGuard VPN** - Secure remote access to your home network
- **Immich** - Self-hosted photo and video backup solution
- **Jellyfin** - Media server for movies, TV shows, and music
- **Samba (SMB)** - Network file sharing
- **VNC** - Remote desktop access
- **Common utilities** - Shared scripts and tools

## 📋 Prerequisites

- Ubuntu 20.04+ server (tested on Ubuntu 24.04)
- Sudo/root access
- Static local IP address
- Basic understanding of networking

## 🏗️ Architecture
```
┌─────────────────────────────────────────┐
│           Internet                      │
└────────────┬────────────────────────────┘
             │
      ┌──────▼──────┐
      │   Router    │
      │ Port Forward│
      └──────┬──────┘
             │
      ┌──────▼──────────────────────────┐
      │   Home Server (Ubuntu)          │
      │                                 │
      │  ┌─────────────┐               │
      │  │ WireGuard   │ (VPN)         │
      │  └─────────────┘               │
      │                                 │
      │  ┌─────────────┐               │
      │  │   Immich    │ (Photos)      │
      │  └─────────────┘               │
      │                                 │
      │  ┌─────────────┐               │
      │  │  Jellyfin   │ (Media)       │
      │  └─────────────┘               │
      │                                 │
      │  ┌─────────────┐               │
      │  │   Samba     │ (Files)       │
      │  └─────────────┘               │
      │                                 │
      │  ┌─────────────┐               │
      │  │    VNC      │ (Desktop)     │
      │  └─────────────┘               │
      └─────────────────────────────────┘
```

## 📦 Services

### WireGuard VPN
Secure VPN access to your home network from anywhere.

- **Port:** 51820 (UDP)
- **Access:** All home services through encrypted tunnel
- [Setup Guide](./scripts/wireguard/README.md)

### Immich
Modern self-hosted photo and video backup solution (Google Photos alternative).

- **Port:** 2283
- **Features:** Mobile apps, facial recognition, automatic backup
- [Setup Guide](./scripts/immich/README.md)

### Jellyfin
Free media server for your movies, TV shows, and music (Plex alternative).

- **Port:** 8096
- **Features:** Streaming, mobile apps, transcoding
- [Setup Guide](./scripts/jellyfin/README.md)

### Samba (SMB)
Network file sharing for easy access from Windows, Mac, and Linux.

- **Port:** 445
- **Features:** Network drives, file sharing
- [Setup Guide](./scripts/smb/README.md)

### VNC
Remote desktop access to your server's GUI.

- **Port:** 5900
- **Features:** Full desktop access, troubleshooting
- [Setup Guide](./scripts/vnc/README.md)

## 🚀 Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/homelab-setup.git
cd homelab-setup
```

### 2. Run the master setup script
```bash
chmod +x setup.sh
sudo ./setup.sh
```

This interactive script will guide you through setting up all services.

### 3. Or install services individually

**WireGuard (VPN - Install First!):**
```bash
cd scripts/wireguard
chmod +x setup.sh
sudo ./setup.sh
```

**Immich (Photos):**
```bash
cd scripts/immich
chmod +x setup.sh
sudo ./setup.sh
```

**Jellyfin (Media):**
```bash
cd scripts/jellyfin
chmod +x setup.sh
sudo ./setup.sh
```

**Samba (File Sharing):**
```bash
cd scripts/smb
chmod +x setup.sh
sudo ./setup.sh
```

**VNC (Remote Desktop):**
```bash
cd scripts/vnc
chmod +x setup.sh
sudo ./setup.sh
```

## 📖 Documentation

- [Initial Server Setup](./docs/server-setup.md)
- [Network Configuration](./docs/network-config.md)
- [Security Best Practices](./docs/security.md)
- [Troubleshooting Guide](./docs/troubleshooting.md)
- [Backup Strategy](./docs/backup.md)

## 🔧 Recommended Installation Order

1. **Common utilities** - Base packages and configurations
2. **WireGuard** - VPN for secure remote access
3. **Immich** - Photo backup
4. **Jellyfin** - Media server
5. **Samba** - File sharing
6. **VNC** - Remote desktop (optional)

## 🛡️ Security Considerations

- All scripts follow security best practices
- Private keys and sensitive data are never committed
- Services run with minimal required permissions
- Regular updates recommended
- See [Security Guide](./docs/security.md) for details

## 📊 System Requirements

### Minimum
- **CPU:** 2 cores
- **RAM:** 4GB
- **Storage:** 50GB (+ media storage)
- **Network:** 10 Mbps upload

### Recommended
- **CPU:** 4+ cores
- **RAM:** 8GB+
- **Storage:** 500GB+ SSD (+ HDD for media)
- **Network:** 50+ Mbps upload

## 🔄 Updating Services

Each service has an update script:
```bash
cd scripts/<service>
sudo ./update.sh
```

Or update all services:
```bash
sudo ./update-all.sh
```

## 🗑️ Uninstalling

To remove a service:
```bash
cd scripts/<service>
sudo ./uninstall.sh
```

## 🤝 Contributing

Contributions welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Test thoroughly
4. Submit a pull request

## 📝 License

MIT License - see [LICENSE](LICENSE) file

## ⚠️ Disclaimer

These scripts are provided as-is. Always review scripts before running them with sudo privileges. Back up your data regularly.

## 🙏 Acknowledgments

- [WireGuard](https://www.wireguard.com/)
- [Immich](https://immich.app/)
- [Jellyfin](https://jellyfin.org/)
- [Samba](https://www.samba.org/)
- Ubuntu community

## 📞 Support

- Create an issue for bugs or questions
- Check [Troubleshooting Guide](./docs/troubleshooting.md)
- Review individual service documentation

---

**Built with ❤️ for homelabbers**

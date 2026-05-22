# Xubh OS

**Penetration Testing Distribution** — Kali Linux based, built with live-build.

## Quick Start

### Prerequisites (Debian/Ubuntu/Kali build machine)

```bash
sudo apt update
sudo apt install -y live-build debootstrap git wget cpio xorriso mtools
sudo apt install -y inkscape  # optional, for PNG asset generation
```

### Build the ISO

```bash
git clone <repo-url> xubh-os
cd xubh-os

# Generate assets (wallpaper, logos, etc.)
./scripts/generate-assets.sh

# Build the ISO
sudo ./build.sh
```

Or using make:

```bash
sudo make assets   # generate PNGs from SVGs
sudo make          # build the ISO
```

Output ISO: `output/xubh-os-kali-rolling-amd64.iso`

### Custom Build Options

```bash
XB_ARCH=i386 sudo ./build.sh        # 32-bit build
XB_DIST=bookworm sudo ./build.sh    # Debian 12 base
```

### Write to USB

```bash
sudo dd if=output/xubh-os-*.iso of=/dev/sdX bs=4M status=progress
```

## Project Structure

```
xubh-os/
├── build.sh                 # Master build script
├── Makefile                 # Build targets
├── auto/                    # live-build automation
├── config/
│   ├── package-lists/       # Package selection
│   ├── includes.chroot/     # Files copied into the live system
│   ├── hooks/               # Custom build hooks
│   ├── includes.binary/     # Files on the ISO (isolinux, etc.)
│   └── archives/            # Custom apt repositories
├── assets/                  # Source SVGs for branding
├── scripts/                 # Helper utilities
└── output/                  # Built ISO (gitignored)
```

## Features

- **Base**: Kali Rolling (Debian Testing)
- **Desktop**: XFCE with dark theme, Xubh branding
- **Tools**: Full pentesting suite (nmap, metasploit, burpsuite, hashcat, etc.)
- **Live**: Bootable ISO with persistence support
- **Branding**: Custom GRUB, Plymouth, wallpaper, login screen

## Persistence

Boot with **"Live with Persistence"** from the GRUB menu. See `/usr/share/xubh/persistence.txt` inside the live system for setup instructions.

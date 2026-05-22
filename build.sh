#!/usr/bin/env bash
# Xubh OS - Master Build Script
# Clones Kali live-build config and overlays Xubh branding
set -euo pipefail

XB_BUILD_DIR="$(cd "$(dirname "$0")" && pwd)"
XB_OUTPUT_DIR="${XB_BUILD_DIR}/output"
XB_LOG_FILE="${XB_BUILD_DIR}/build.log"
XB_ARCH="${XB_ARCH:-amd64}"
XB_DIST="${XB_DIST:-kali-rolling}"
KALI_LB_REPO="https://gitlab.com/kalilinux/build-scripts/live-build-config.git"

log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "${XB_LOG_FILE}"; }

check_deps() {
    local deps=(live-build debootstrap git wget cpio xorriso mtools)
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            log "ERROR: $dep is not installed. Run: sudo apt install live-build debootstrap git wget cpio xorriso mtools"
            exit 1
        fi
    done
}

prepare_env() {
    log "Preparing build environment..."
    rm -rf "${XB_OUTPUT_DIR}" "${XB_BUILD_DIR}/.build"
    mkdir -p "${XB_OUTPUT_DIR}"
}

clone_kali_config() {
    log "Cloning Kali live-build config..."
    if [ -d "${XB_BUILD_DIR}/.build/live-build-config" ]; then
        cd "${XB_BUILD_DIR}/.build/live-build-config"
        git pull
    else
        mkdir -p "${XB_BUILD_DIR}/.build"
        git clone --depth=1 "${KALI_LB_REPO}" "${XB_BUILD_DIR}/.build/live-build-config"
    fi
}

overlay_xubh_branding() {
    log "Applying Xubh OS branding over Kali..."
    local KALI_DIR="${XB_BUILD_DIR}/.build/live-build-config"
    local XUBH_OVERLAY="${XB_BUILD_DIR}/overlay"

    # 1. Replace OS name in auto/config
    sed -i 's/kali/xubh/gi' "${KALI_DIR}/auto/config" 2>/dev/null || true
    sed -i 's/Kali/Xubh/g' "${KALI_DIR}/auto/config" 2>/dev/null || true

    # 2. Replace boot hostname/username
    sed -i 's/username=kali/username=xubh/g' "${KALI_DIR}/auto/config" 2>/dev/null || true
    sed -i 's/hostname=kali/hostname=xubh/g' "${KALI_DIR}/auto/config" 2>/dev/null || true

    # 3. Overlay branding files (wallpaper, grub, plymouth, etc.)
    if [ -d "${XUBH_OVERLAY}" ]; then
        cp -rv "${XUBH_OVERLAY}/"* "${KALI_DIR}/" 2>/dev/null || true
    fi

    # 4. Replace /etc/os-release and /etc/hostname
    mkdir -p "${KALI_DIR}/config/includes.chroot/etc/"
    cat > "${KALI_DIR}/config/includes.chroot/etc/os-release" << 'OSR'
PRETTY_NAME="Xubh OS"
NAME="Xubh OS"
ID=xubh
ID_LIKE=debian
ANSI_COLOR="1;31"
HOME_URL="https://xubh-os.org"
SUPPORT_URL="https://xubh-os.org/support"
BUG_REPORT_URL="https://xubh-os.org/bugs"
VERSION_ID="1.0"
VERSION="1.0"
VERSION_CODENAME=ganesha
LOGO="xubh-logo"
OSR

    echo "xubh" > "${KALI_DIR}/config/includes.chroot/etc/hostname"

    cat > "${KALI_DIR}/config/includes.chroot/etc/hosts" << 'HOSTS'
127.0.0.1	localhost
127.0.1.1	xubh

::1		localhost ip6-localhost ip6-loopback
fe00::0		ip6-localnet
ff00::0		ip6-mcastprefix
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters
HOSTS

    # 5. Replace bash prompt: kali -> xubh
    local SKEL_DIR="${KALI_DIR}/config/includes.chroot/etc/skel"
    mkdir -p "${SKEL_DIR}"
    cat > "${SKEL_DIR}/.bashrc" << 'BASHRC'
# Xubh OS - default .bashrc (Kali-style)
PS1='\[\e[31m\]┌──\[\e[0m\](\[\e[31m\]xubh㉿\h\[\e[0m\])─[\e[31m\]\w\[\e[0m\]\n\[\e[31m\]└─\[\e[0m\]\[\e[31m\]\$\[\e[0m\] '
alias ll='ls -la'
alias la='ls -A'
alias l='ls -CF'
alias cls='clear'
alias xubh-update='sudo apt update && sudo apt full-upgrade -y'
export EDITOR=vim
export TERM=xterm-256color
BASHRC

    mkdir -p "${KALI_DIR}/config/includes.chroot/root"
    cp "${SKEL_DIR}/.bashrc" "${KALI_DIR}/config/includes.chroot/root/.bashrc"
    sed -i 's/\\$/#/' "${KALI_DIR}/config/includes.chroot/root/.bashrc"

    # 6. Replace LightDM greeter background
    mkdir -p "${KALI_DIR}/config/includes.chroot/etc/lightdm/"
    cat > "${KALI_DIR}/config/includes.chroot/etc/lightdm/lightdm-gtk-greeter.conf" << 'LIGHTDM'
[greeter]
background = /usr/share/backgrounds/xubh-wallpaper.png
theme-name = Kali-Dark
icon-theme-name = Papirus-Dark
font-name = DejaVu Sans 11
user-background = false
indicators = ~host;~spacer;~clock;~spacer;~power
LIGHTDM

    # 7. Override GRUB background
    mkdir -p "${KALI_DIR}/config/includes.chroot/usr/share/grub/themes/xubh"
    cat > "${KALI_DIR}/config/includes.chroot/usr/share/grub/themes/xubh/theme.txt" << 'GRUB'
title-text: "XUBH OS"
title-font: "DejaVu Sans Bold 18"
title-color: "#FF3333"
title-align: "center"
desktop-image: "background.png"
desktop-color: "#1a1a1a"
terminal-font: "DejaVu Sans 12"
+ boot_menu {
    left = 25%
    top = 20%
    width = 50%
    height = 60%
    align = "center"
    item_color = "#cccccc"
    selected_item_color = "#FF3333"
    item_height = 32
    item_padding = 8
    item_spacing = 4
    item_font = "DejaVu Sans 14"
    selected_item_font = "DejaVu Sans Bold 14"
    scrollbar = true
}
+ progress_bar {
    top = 90%
    left = 20%
    width = 60%
    height = 12
    bar_color = "#FF3333"
    bar_bg_color = "#333333"
}
GRUB

    # Enable GRUB theme
    mkdir -p "${KALI_DIR}/config/includes.chroot/etc/default/grub.d/"
    cat > "${KALI_DIR}/config/includes.chroot/etc/default/grub.d/xubh-theme.cfg" << 'GRUBCFG'
GRUB_THEME="/usr/share/grub/themes/xubh/theme.txt"
GRUB_TIMEOUT=5
GRUB_TIMEOUT_STYLE=menu
GRUBCFG

    # 8. Plymouth theme
    mkdir -p "${KALI_DIR}/config/includes.chroot/usr/share/plymouth/themes/xubh"
    cat > "${KALI_DIR}/config/includes.chroot/usr/share/plymouth/themes/xubh/xubh.plymouth" << 'PLYMOUTH'
[Plymouth Theme]
Name=Xubh OS
Description=Xubh OS Boot Splash
ModuleName=script
[script]
ImageDir=/usr/share/plymouth/themes/xubh
ScriptFile=/usr/share/plymouth/themes/xubh/xubh.script
PLYMOUTH

    cat > "${KALI_DIR}/config/includes.chroot/usr/share/plymouth/themes/xubh/xubh.script" << 'PLYSCRIPT'
Wallpaper.SetTiling(false);
logo = Image("xubh-logo.png");
logo_sprite = Sprite();
logo_sprite.SetImage(logo);
screen_width = Window.GetWidth();
screen_height = Window.GetHeight();
logo_sprite.SetPosition(screen_width / 2 - 75, screen_height / 2 - 100, 150, 150);
logo_sprite.SetOpacity(1.0);
message = Text("Xubh OS");
message.SetFontName("DejaVu Sans Bold");
message.SetFontSize(28);
message.SetColor(1.0, 0.2, 0.2, 1.0);
msg_x = screen_width / 2 - message.GetWidth() / 2;
msg_y = screen_height / 2 + 40;
message.SetPosition(msg_x, msg_y);
message.SetOpacity(1.0);
subtitle = Text("Penetration Testing Distribution");
subtitle.SetFontName("DejaVu Sans");
subtitle.SetFontSize(14);
subtitle.SetColor(0.6, 0.6, 0.6, 1.0);
sub_x = screen_width / 2 - subtitle.GetWidth() / 2;
sub_y = msg_y + 35;
subtitle.SetPosition(sub_x, sub_y);
subtitle.SetOpacity(1.0);
PLYSCRIPT

    # Set default plymouth theme
    mkdir -p "${KALI_DIR}/config/includes.chroot/etc/plymouth/"
    echo "[Daemon]" > "${KALI_DIR}/config/includes.chroot/etc/plymouth/plymouthd.conf"
    echo "Theme=xubh" >> "${KALI_DIR}/config/includes.chroot/etc/plymouth/plymouthd.conf"

    # 9. Wallpaper
    mkdir -p "${KALI_DIR}/config/includes.chroot/usr/share/backgrounds/"
    # Use Kali's default wallpaper but rename it (or copy our SVG converted later)

    # 10. Welcome message
    mkdir -p "${KALI_DIR}/config/includes.chroot/usr/local/bin/"
    cat > "${KALI_DIR}/config/includes.chroot/usr/local/bin/xubh-welcome" << 'WELCOME'
#!/bin/bash
neofetch
echo ""
echo "  Quick commands:"
echo "    xubh-update  - Update Xubh OS"
echo "    xubh-menu    - Open tools menu"
echo ""
WELCOME
    chmod +x "${KALI_DIR}/config/includes.chroot/usr/local/bin/xubh-welcome"

    # Auto-start welcome on first login
    mkdir -p "${KALI_DIR}/config/includes.chroot/etc/skel/.config/autostart/"
    cat > "${KALI_DIR}/config/includes.chroot/etc/skel/.config/autostart/xubh-welcome.desktop" << 'AUTOSTART'
[Desktop Entry]
Type=Application
Name=Xubh Welcome
Exec=xubh-welcome
OnlyShowIn=XFCE;
NoDisplay=false
AUTOSTART

    log "Branding overlay applied successfully!"
}

build_iso() {
    log "Building Xubh OS ISO from Kali config..."
    cd "${XB_BUILD_DIR}/.build/live-build-config"

    log "Running lb build (this will take 1-2 hours)..."
    sudo ./build.sh --distribution "${XB_DIST}" --arch "${XB_ARCH}" 2>&1 | tee -a "${XB_LOG_FILE}"

    if ls kali-linux-*.iso 1>/dev/null 2>&1; then
        for f in kali-linux-*.iso; do
            mv "$f" "${XB_OUTPUT_DIR}/xubh-os-${XB_DIST}-${XB_ARCH}.iso"
        done
        log "SUCCESS: ISO built at ${XB_OUTPUT_DIR}/xubh-os-${XB_DIST}-${XB_ARCH}.iso"
        ls -lh "${XB_OUTPUT_DIR}/"
    elif ls live-image-*.hybrid.iso 1>/dev/null 2>&1; then
        for f in live-image-*.hybrid.iso; do
            mv "$f" "${XB_OUTPUT_DIR}/xubh-os-${XB_DIST}-${XB_ARCH}.iso"
        done
        log "SUCCESS: ISO built at ${XB_OUTPUT_DIR}/xubh-os-${XB_DIST}-${XB_ARCH}.iso"
        ls -lh "${XB_OUTPUT_DIR}/"
    else
        log "ERROR: ISO build failed - no output ISO found"
        exit 1
    fi
}

cleanup() {
    log "Cleaning up..."
    cd "${XB_BUILD_DIR}/.build/live-build-config" 2>/dev/null && sudo lb clean --purge 2>/dev/null || true
}

main() {
    log "=== Xubh OS Build (Kali Clone) ==="
    check_deps
    prepare_env
    clone_kali_config
    overlay_xubh_branding
    build_iso
    cleanup
    log "Build complete!"
}

main "$@"

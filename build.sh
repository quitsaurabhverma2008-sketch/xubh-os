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
    mkdir -p "${XB_OUTPUT_DIR}" "${XB_BUILD_DIR}/.build"
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
    log "Applying Xubh OS branding..."
    local KALI_DIR="${XB_BUILD_DIR}/.build/live-build-config"
    local XUBH_OVERLAY="${XB_BUILD_DIR}/overlay"

    # Fix hostname/username in auto/config (targeted, safe replacements)
    sed -i 's/username=kali/username=xubh/g' "${KALI_DIR}/auto/config"
    sed -i 's/hostname=kali/hostname=xubh/g' "${KALI_DIR}/auto/config"
    sed -i 's/"kali"/"xubh"/g' "${KALI_DIR}/auto/config"

    # Copy overlay branding files
    if [ -d "${XUBH_OVERLAY}" ]; then
        cp -rv "${XUBH_OVERLAY}/"* "${KALI_DIR}/" 2>/dev/null || true
    fi

    # Ensure os-release
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

    log "Branding overlay applied!"
}

build_iso() {
    log "Building Xubh OS ISO..."
    local BUILD_DIR="${XB_BUILD_DIR}/.build"
    local KALI_DIR="${BUILD_DIR}/live-build-config"

    cd "${KALI_DIR}"

    # Configure using Kali's auto/config (we already patched it above)
    log "Running lb config..."
    sudo lb config -a "${XB_ARCH}" --distribution "${XB_DIST}" \
        -- --variant default 2>&1 | tee -a "${XB_LOG_FILE}"

    # Build
    log "Running lb build (1-2 hours)..."
    sudo lb build 2>&1 | tee -a "${XB_LOG_FILE}"

    # Find the ISO
    local iso_file=""
    if ls live-image-*.hybrid.iso 1>/dev/null 2>&1; then
        iso_file=$(ls live-image-*.hybrid.iso | head -1)
    elif ls kali-linux-*.iso 1>/dev/null 2>&1; then
        iso_file=$(ls kali-linux-*.iso | head -1)
    fi

    if [ -n "$iso_file" ] && [ -f "$iso_file" ]; then
        mv "$iso_file" "${XB_OUTPUT_DIR}/xubh-os-${XB_DIST}-${XB_ARCH}.iso"
        log "SUCCESS: ISO at ${XB_OUTPUT_DIR}/xubh-os-${XB_DIST}-${XB_ARCH}.iso"
        ls -lh "${XB_OUTPUT_DIR}/"
    else
        log "ERROR: ISO not found. Check build.log"
        exit 1
    fi
}

main() {
    log "=== Xubh OS Build ==="
    check_deps
    prepare_env
    clone_kali_config
    overlay_xubh_branding
    build_iso
    log "Build complete!"
}

main "$@"

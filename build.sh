#!/usr/bin/env bash
# Xubh OS - Master Build Script
# Builds a Kali-like penetration testing Linux distribution
set -euo pipefail

XB_BUILD_DIR="$(cd "$(dirname "$0")" && pwd)"
XB_OUTPUT_DIR="${XB_BUILD_DIR}/output"
XB_LOG_FILE="${XB_BUILD_DIR}/build.log"
XB_ARCH="${XB_ARCH:-amd64}"
XB_DIST="${XB_DIST:-kali-rolling}"

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

build_iso() {
    log "Starting ISO build..."
    cd "${XB_BUILD_DIR}/.build"

    lb config \
        --architecture "${XB_ARCH}" \
        --distribution "${XB_DIST}" \
        --archive-areas "main contrib non-free non-free-firmware" \
        --binary-images "iso-hybrid" \
        --bootappend-live "boot=live components quiet splash username=xubh hostname=xubh" \
        --debian-installer false \
        --linux-packages "linux-image linux-headers" \
        --memtest none \
        --iso-application "Xubh OS - Penetration Testing Distribution" \
        --iso-preparer "Xubh OS Team" \
        --iso-publisher "Xubh OS" \
        --iso-volume "Xubh OS ${XB_DIST}" \
        --mode debian \
        --parent-mirror-bootstrap "http://http.kali.org/kali" \
        --parent-mirror-binary "http://http.kali.org/kali" \
        --parent-debian-installer-distribution "${XB_DIST}" \
        --apt-recommends true \
        --apt-secure true \
        --firmware-binary true \
        --firmware-chroot true

    cp -r "${XB_BUILD_DIR}/config/"* config/ 2>/dev/null || true

    log "Running lb build (this will take a long time)..."
    sudo lb build 2>&1 | tee -a "${XB_LOG_FILE}"

    if ls live-image-*.hybrid.iso 1>/dev/null 2>&1; then
        mv live-image-*.hybrid.iso "${XB_OUTPUT_DIR}/xubh-os-${XB_DIST}-${XB_ARCH}.iso"
        log "SUCCESS: ISO built at ${XB_OUTPUT_DIR}/xubh-os-${XB_DIST}-${XB_ARCH}.iso"
    else
        log "ERROR: ISO build failed - no output ISO found"
        exit 1
    fi
}

cleanup() {
    log "Cleaning up..."
    sudo lb clean --purge 2>/dev/null || true
}

main() {
    log "=== Xubh OS Build ==="
    check_deps
    prepare_env
    build_iso
    cleanup
    log "Build complete!"
}

main "$@"

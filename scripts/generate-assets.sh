#!/bin/bash
# Xubh OS - Asset Generator
# Converts SVG source files to PNG for use in the distribution
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

INKSCAPE=$(command -v inkscape || true)
MAGICK=$(command -v convert || true)

if [ -z "$INKSCAPE" ] && [ -z "$MAGICK" ]; then
    echo "ERROR: Neither Inkscape nor ImageMagick found."
    echo "Install one of:"
    echo "  sudo apt install inkscape"
    echo "  sudo apt install imagemagick"
    exit 1
fi

render() {
    local src="$1" dst="$2" w="$3" h="$4"
    mkdir -p "$(dirname "$dst")"
    if [ -n "$INKSCAPE" ]; then
        echo "  [inkscape] $src -> $dst (${w}x${h})"
        "$INKSCAPE" --export-type=png --export-filename="$dst" \
            --export-width="$w" --export-height="$h" "$src" 2>/dev/null
    elif [ -n "$MAGICK" ]; then
        echo "  [convert] $src -> $dst (${w}x${h})"
        "$MAGICK" -background none -size "${w}x${h}" "$src" "$dst"
    fi
}

echo "=== Generating Xubh OS Assets ==="
echo ""

echo "1/5: Plymouth boot logo"
render "${PROJECT_DIR}/assets/logo.svg" \
    "${PROJECT_DIR}/config/includes.chroot/usr/share/plymouth/themes/xubh/xubh-logo.png" \
    150 150

echo "2/5: Desktop wallpaper"
render "${PROJECT_DIR}/assets/wallpaper.svg" \
    "${PROJECT_DIR}/config/includes.chroot/usr/share/backgrounds/xubh-wallpaper.png" \
    1920 1080

echo "3/5: GRUB background"
render "${PROJECT_DIR}/assets/wallpaper.svg" \
    "${PROJECT_DIR}/config/includes.chroot/usr/share/grub/themes/xubh/background.png" \
    1024 768

echo "4/5: GRUB logo"
render "${PROJECT_DIR}/assets/logo.svg" \
    "${PROJECT_DIR}/config/includes.chroot/usr/share/grub/themes/xubh/logo.png" \
    256 256

echo "5/5: ISOLINUX splash"
render "${PROJECT_DIR}/assets/wallpaper.svg" \
    "${PROJECT_DIR}/config/includes.binary/isolinux/splash.png" \
    640 480

echo ""
echo "Done! All assets generated."

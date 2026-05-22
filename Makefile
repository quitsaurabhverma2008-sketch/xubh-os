# Xubh OS Makefile
.PHONY: all clean iso assets

all: iso

iso:
	./build.sh

assets:
	@echo "Generating assets from SVG sources..."
	@echo "Install Inkscape or ImageMagick to render SVGs to PNG:"
	@echo "  sudo apt install inkscape"
	@echo "  cd assets && inkscape logo.svg -o ../config/includes.chroot/usr/share/plymouth/themes/xubh/xubh-logo.png -w 150 -h 150"
	@echo "  inkscape wallpaper.svg -o ../config/includes.chroot/usr/share/backgrounds/xubh-wallpaper.png -w 1920 -h 1080"
	@echo "  inkscape wallpaper.svg -o ../config/includes.binary/isolinux/splash.png -w 640 -h 480"
	@echo "  inkscape logo.svg -o ../config/includes.chroot/usr/share/grub/themes/xubh/background.png -w 1024 -h 768"
	@echo "  inkscape logo.svg -o ../config/includes.chroot/usr/share/grub/themes/xubh/logo.png -w 256 -h 256"

clean:
	rm -rf output/ .build/
	sudo lb clean --purge 2>/dev/null || true

distclean: clean
	rm -rf config/binary config/bootstrap config/build config/chroot config/common config/source
	rm -rf config/hooks/normal/*.chroot 2>/dev/null || true

help:
	@echo "Xubh OS Build System"
	@echo ""
	@echo "Targets:"
	@echo "  make          - Build Xubh OS ISO (same as 'make iso')"
	@echo "  make iso      - Build the ISO image"
	@echo "  make assets   - Generate PNG assets from SVG sources"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make distclean- Full cleanup (removes live-build config)"
	@echo ""
	@echo "Requirements:"
	@echo "  sudo apt install live-build debootstrap git wget cpio xorriso mtools"
	@echo "  sudo apt install inkscape  (for asset generation)"
	@echo ""
	@echo "Usage:"
	@echo "  # Build the ISO"
	@echo "  sudo make iso"
	@echo ""
	@echo "  # Customize via environment variables:"
	@echo "  XB_ARCH=i386 sudo make iso"
	@echo "  XB_DIST=bookworm sudo make iso"

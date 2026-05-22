# Xubh OS - Kali Clone Makefile
.PHONY: all clean iso assets

all: iso

iso:
	sudo ./build.sh

assets:
	@echo "Generating assets from SVG..."
	./scripts/generate-assets.sh

clean:
	rm -rf output/ .build/
	sudo lb clean --purge 2>/dev/null || true

help:
	@echo "Xubh OS - Kali Linux Clone"
	@echo ""
	@echo "Targets:"
	@echo "  make iso      - Build Xubh OS ISO"
	@echo "  make assets   - Generate PNG assets from SVG"
	@echo "  make clean    - Clean build artifacts"
	@echo ""
	@echo "Requirements: sudo apt install live-build debootstrap git wget cpio xorriso mtools inkscape"

# Xubh OS

**Kali Linux ki exact copy — sirf naam Xubh OS hai.** Har command, har tool, har repository, har config bilkul Kali jaisi.

## Kya hai ye?

Yeh **Kali Linux ka 1:1 clone** hai. Bas branding badli gayi:
- Kali → **Xubh OS**
- kali@hostname → **xubh@hostname**
- Kali wallpaper/GRUB → **Xubh red theme**
- Baaki sab kuch **bilkul waisa hi** hai

## Build kaise karein?

**Linux machine (Debian/Kali) pe:**

```bash
# Dependencies install karein
sudo apt update
sudo apt install -y live-build debootstrap git wget cpio xorriso mtools

# Repo clone karein
git clone <your-repo-url> xubh-os
cd xubh-os

# Assets generate karein (SVG -> PNG)
sudo apt install -y inkscape
./scripts/generate-assets.sh

# ISO build karein
sudo ./build.sh
```

Output: `output/xubh-os-kali-rolling-amd64.iso`

## Kya kya same hai?

| Feature | Kali Linux | Xubh OS |
|---------|-----------|---------|
| Commands | ✅ Same | ✅ Same |
| Tools | ✅ Same | ✅ Same |
| Repositories | ✅ kali-rolling | ✅ kali-rolling |
| Desktop | ✅ XFCE | ✅ XFCE |
| Packages | ✅ Same list | ✅ Same list |
| Prompt style | ✅ kali㉿ | ✅ xubh㉿ (same style) |

## Sirf kya badla?

- OS name: "Xubh OS"
- Wallpaper: Xubh red-on-black theme
- GRUB screen: "XUBH OS"
- Boot splash: Xubh logo
- Hostname: `xubh`
- Default user: `xubh`

## USB mein daalna

```bash
sudo dd if=output/xubh-os-*.iso of=/dev/sdX bs=4M status=progress
```

## Build kaise kaam karta hai?

1. Kali Linux ka official live-build config clone hota hai
2. Upar Xubh branding (name, wallpaper, GRUB, plymouth) overlay hoti hai
3. `lb build` se ISO banta hai

**Kali ka code — Xubh ka brand.**

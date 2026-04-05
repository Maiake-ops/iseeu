#!/bin/bash
set -e

echo "=== Gentoo Auto Installer (v3 + arch-chroot) ==="

--- Disk ---

read -p "Enter disk (e.g. /dev/nvme0n1): " DISK
[[ -b "$DISK" ]] || { echo "Disk not found"; exit 1; }

--- Root partition ---

read -p "Enter root partition (e.g. /dev/nvme0n1p2): " ROOT_PART
[[ "$ROOT_PART" == /dev/* && -b "$ROOT_PART" ]] || { echo "Invalid root partition"; exit 1; }

--- GRUB disk ---

read -p "Enter GRUB disk (e.g. /dev/nvme0n1 or none): " GRUB_DISK
if [[ "$GRUB_DISK" == /dev/* && ! -b "$GRUB_DISK" ]]; then
echo "Invalid GRUB disk → skipping"
GRUB_DISK="none"
fi

--- Home partition ---

read -p "Separate /home? (y/n): " HOME_CHOICE
if [[ "$HOME_CHOICE" == "y" ]]; then
read -p "Enter home partition: " HOME_PART
[[ "$HOME_PART" == /dev/* && -b "$HOME_PART" ]] || { echo "Invalid home partition"; exit 1; }
fi

--- Mount ---

echo "[*] Mounting root..."
mount "$ROOT_PART" /mnt/gentoo
mkdir -p /mnt/gentoo/home

if [[ "$HOME_CHOICE" == "y" ]]; then
mount "$HOME_PART" /mnt/gentoo/home
fi

--- Stage3 ---

cd /mnt/gentoo
echo "[*] Fetching stage3..."
wget -q https://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64.txt
STAGE=$(grep stage3 latest-stage3-amd64.txt | tail -n1 | awk '{print $1}')
wget https://distfiles.gentoo.org/releases/amd64/autobuilds/$STAGE

echo "[] Extracting stage3..."
tar xpvf stage3-.tar.xz --xattrs-include='.' --numeric-owner

cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

--- Enter chroot ---

arch-chroot /mnt/gentoo /bin/bash <<EOF

source /etc/profile

echo "=== CPU Check for x86-64-v3 ==="
CPU_FLAGS=$(grep -m1 flags /proc/cpuinfo)

if echo "$CPU_FLAGS" | grep -qw avx2 && 
echo "$CPU_FLAGS" | grep -qw bmi1 && 
echo "$CPU_FLAGS" | grep -qw bmi2 && 
echo "$CPU_FLAGS" | grep -qw fma && 
echo "$CPU_FLAGS" | grep -qw movbe && 
echo "$CPU_FLAGS" | grep -qw xsave; then

echo "[+] CPU supports x86-64-v3 → enabling binpkg"

echo 'COMMON_FLAGS="-O2 -pipe -march=x86-64-v3"' >> /etc/portage/make.conf
echo 'CFLAGS="\${COMMON_FLAGS}"' >> /etc/portage/make.conf
echo 'CXXFLAGS="\${COMMON_FLAGS}"' >> /etc/portage/make.conf

echo 'FEATURES="getbinpkg"' >> /etc/portage/make.conf
echo 'PORTAGE_BINHOST="https://distfiles.gentoo.org/releases/amd64/binpackages/23.0/x86-64-v3/"' >> /etc/portage/make.conf

fi

echo "=== Sync ==="
emerge-webrsync
emerge --sync

echo "=== Profile Selection ==="
eselect profile list
while true; do
read -p "Select profile number: " PROF
eselect profile set $PROF && break || echo "Invalid, try again"
done

--- Firmware license fix ---

echo "=== Enabling linux-firmware license ==="
mkdir -p /etc/portage/package.license
echo "sys-kernel/linux-firmware linux-fw-redistributable" >> /etc/portage/package.license/linux-firmware

emerge sys-kernel/linux-firmware

--- Kernel ---

echo "=== Kernel ==="
echo "1) gentoo (manual)"
echo "2) zen (manual patch)"
echo "3) hardened"
echo "4) lts (bin)"

read -p "Choose: " KSEL

case $KSEL in
1) emerge sys-kernel/gentoo-sources ;;
2) emerge sys-kernel/gentoo-sources ;;
3) emerge sys-kernel/hardened-sources ;;
4) emerge sys-kernel/gentoo-kernel-bin ;;
*) echo "Invalid"; exit 1 ;;
esac

if [[ "$KSEL" != "4" ]]; then
emerge sys-kernel/genkernel
genkernel all
fi

emerge sys-boot/grub

--- os-prober ---

read -p "Enable os-prober for dual boot? (y/n): " OSP
if [[ "$OSP" == "y" ]]; then
emerge sys-boot/os-prober
echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub
fi

--- Desktop ---

echo "=== Desktop ==="
echo "1) none"
echo "2) XFCE"
echo "3) KDE"
echo "4) Hyprland"

read -p "Choose: " DSEL

case $DSEL in
2) emerge xfce-base/xfce4-meta ;;
3) emerge kde-plasma/plasma-meta ;;
4) emerge gui-wm/hyprland ;;
esac

--- User ---

echo "=== User Setup ==="
read -p "Username: " USERNAME
useradd -m -G wheel $USERNAME

echo "Set user password:"
passwd $USERNAME

echo "Set root password:"
passwd

--- Extra packages ---

echo "=== Extra packages ==="
read -p "Enter packages: " PKGS
emerge $PKGS

--- GRUB ---

echo "=== GRUB Install ==="
if [[ "$GRUB_DISK" != "none" ]]; then
grub-install $GRUB_DISK
fi

grub-mkconfig -o /boot/grub/grub.cfg

echo "=== DONE ==="
EOF

echo "Installation complete. Reboot."
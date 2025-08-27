#!/bin/bash
# Install MikroTik Cloud Hosted Router (CHR) 7.19.4 onto the current VPS disk.
# DANGER: This WILL overwrite the whole system disk immediately (no confirmation).
# Intended for quick deployment of CHR on a new VPS.  
# Tested on Debian 12, Ubuntu 25.04, CentOS 9, Rocky Linux 9.
# Author: Ihor Hreskiv
# Date: 2025-08-27
# Version: 2.1
#############################################
# quick usage: 
# change password: NEW_PASSWORD='S3cure!Pass' ./chr-install.sh
# change identity: IDENTITY='chr-cloud' ./chr-install.sh
#############################################


set -euo pipefail

# -------- Fixed config --------
ROS_VER="7.19.4"
ROS_ZIP_URL="https://download.mikrotik.com/routeros/${ROS_VER}/chr-${ROS_VER}.img.zip"


# Optional env overrides
NEW_PASSWORD="${NEW_PASSWORD:-changeMeNOW!}"     # pass via env to avoid editing script
IDENTITY="${IDENTITY:-chr-${ROS_VER}}"
TARGET_DISK="${TARGET_DISK:-}"                   # e.g. /dev/vda (auto-detected if empty)

WORKDIR="/tmp/chr-inst"
MNT="/mnt/chr"

# -------- Install wget/unzip if missing --------
if command -v yum >/dev/null; then
  yum install -y wget unzip
elif command -v dnf >/dev/null; then
  dnf install -y wget unzip
elif command -v apt-get >/dev/null; then
  apt-get install -y wget unzip
fi


# -------- Checks --------
[[ $EUID -eq 0 ]] || { echo "Run as root."; exit 1; }

need_bins=(wget losetup mount umount awk ip dd lsblk findmnt)
for b in "${need_bins[@]}"; do
  command -v "$b" >/dev/null || { echo "Missing required tool: $b"; exit 1; }
done


# -------- Prep --------
mkdir -p "$WORKDIR" "$MNT"
cleanup() {
  set +e
  mountpoint -q "$MNT" && umount "$MNT"
  if [[ -n "${LOOPDEV:-}" ]]; then
    losetup -d "$LOOPDEV" 2>/dev/null || true
  fi
}
trap cleanup EXIT


echo "[*] Downloading CHR image ${ROS_VER}..."
cd "$WORKDIR"
wget -q "$ROS_ZIP_URL" -O chr.img.zip

echo "[*] Unzipping..."
if command -v unzip >/dev/null; then
  unzip -p chr.img.zip > chr.img
else
  bsdtar -O -xf chr.img.zip > chr.img
fi

echo "[*] Attaching loop device..."
LOOPDEV=$(losetup --show -Pf chr.img)
sleep 1

echo "[*] Searching for partition with 'rw/'..."
found=""
for part in "${LOOPDEV}"p{1..8}; do
  [[ -e "$part" ]] || continue
  umount "$MNT" 2>/dev/null || true
  mount "$part" "$MNT" 2>/dev/null || continue
  if [[ -d "$MNT/rw" ]]; then
    found="$part"
    echo "    -> Found on $part"
    break
  fi
done
[[ -n "$found" ]] || { echo "Failed to find 'rw/' in image partitions."; exit 1; }

# -------- Network detection (static IPv4) --------
IFACE=$(ip route show default 0.0.0.0/0 | awk '/default/ {print $5; exit}')
[[ -n "${IFACE:-}" ]] || { echo "No default interface detected."; exit 1; }

ADDR="$(ip -o -4 addr show dev "$IFACE" | awk '{print $4}' | head -n1 || true)"
GW="$(ip -4 route show default | awk '/default/ {print $3; exit}' || true)"
[[ -n "$ADDR" && -n "$GW" ]] || {
  echo "IPv4 or gateway not detected; cannot configure static networking."
  exit 1
}
echo "[*] Network (static): IFACE=$IFACE ADDR=$ADDR GW=$GW"

# -------- Write autorun.scr --------
echo "[*] Writing autorun.scr ..."
cat > "$MNT/rw/autorun.scr" <<EOF
/ip address add address=${ADDR} interface=[/interface ethernet find where name=ether1]
/ip route add gateway=${GW}
/user set 0 password=${NEW_PASSWORD}
/system identity set name="${IDENTITY}"
/ip dns set servers=8.8.8.8
ip/service/set disabled=yes api,api-ssl,telnet,ftp
EOF

ls -l "$MNT/rw/autorun.scr" >/dev/null

sync
umount "$MNT"
losetup -d "$LOOPDEV"
unset LOOPDEV

# -------- Determine target disk --------
if [[ -z "$TARGET_DISK" ]]; then
  ROOTSRC=$(findmnt -no SOURCE /)
  PARENT=$(lsblk -no pkname "$ROOTSRC" 2>/dev/null || true)
  if [[ -n "$PARENT" ]]; then
    TARGET_DISK="/dev/$PARENT"
  else
    TARGET_DISK="$ROOTSRC"
  fi
fi

# Normalize nvme partition cases: /dev/nvme0n1p2 -> /dev/nvme0n1
case "$TARGET_DISK" in
  /dev/nvme*n*p*) TARGET_DISK="${TARGET_DISK%p*}";;
  /dev/*[0-9])    TARGET_DISK="${TARGET_DISK%[0-9]*}";;
esac

[[ -b "$TARGET_DISK" ]] || { echo "Target disk not a block device: $TARGET_DISK"; exit 1; }



echo "[*] Flushing and remounting FS read-only..."
echo u > /proc/sysrq-trigger || true
sleep 5

echo "[*] Writing CHR image to ${TARGET_DISK} ..."
dd if="${WORKDIR}/chr.img" of="${TARGET_DISK}" bs=4M iflag=fullblock oflag=direct status=progress

echo "[*] Forcing sync..."
echo s > /proc/sysrq-trigger || true

echo "[*] Immediate reboot..."
echo b > /proc/sysrq-trigger || reboot -f

# --- EOF ---

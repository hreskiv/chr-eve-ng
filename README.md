# MikroTik CHR for EVE-NG
The script `chr-eve.sh` simplifies adding **MikroTik Cloud Hosted Router (CHR)** images into EVE-NG.

## Features
- Automatically downloads CHR image from the official MikroTik CDN:
https://download.mikrotik.com/routeros/<version>/chr-<version>.img.zip

(works for stable, long-term, testing, RC builds – e.g. `7.20rc5`).
- Extracts and converts the image to `qcow2` format as `hda.qcow2`.
- Colored, step-by-step log output.
- Runs `fixpermissions` automatically.
- Provides subcommands:
- `install` — install a new CHR version
- `list` — list installed CHR versions
- `remove` — remove a specific version

## Requirements
```bash
bash, curl, unzip, qemu-img
```

## Usage
### Install

```bash
./chr-eve.sh install --version 7.20
./chr-eve.sh install --version 7.20rc5
./chr-eve.sh install --version 7.20 --force     # overwrite if exists
./chr-eve.sh install --version 7.19.4 --local /tmp/chr-7.19.4.img
```
### List installed CHR images
```bash
sudo ./chr-eve.sh list
```
### Remove a CHR version
```bash
sudo ./chr-eve.sh remove --version 7.19.4
# or by directory name
sudo ./chr-eve.sh remove --name mikrotik-7.19.4
```

## Installation path
### Images are placed in:
```bash
/opt/unetlab/addons/qemu/mikrotik-<version>/hda.qcow2 
```

Then in EVE-NG you can add a node of type mikrotik and choose the installed version.

#### Author: Ihor Hreskiv
#### Updated: 2025

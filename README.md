# MikroTik CHR for EVE-NG

![GitHub Stars](https://img.shields.io/github/stars/hreskiv/chr-eve-ng)
![GitHub Forks](https://img.shields.io/github/forks/hreskiv/chr-eve-ng)
![Shell](https://img.shields.io/badge/language-bash-green)
![License](https://img.shields.io/github/license/hreskiv/chr-eve-ng)

Bash script that automates adding **MikroTik Cloud Hosted Router (CHR)** images into [EVE-NG](https://www.eve-ng.net/). Downloads, converts, and deploys CHR images — ready to use in seconds.

## Quick Start

```bash
# On your EVE-NG server:
curl -O https://raw.githubusercontent.com/hreskiv/chr-eve-ng/master/chr-eve.sh
chmod +x chr-eve.sh
sudo ./chr-eve.sh install --version 7.20
```

The CHR node is now available in EVE-NG — add it to any topology.

## Features

- Downloads CHR images from the official [MikroTik CDN](https://mikrotik.com/download)
- Supports **all release channels**: stable, long-term, testing, RC (e.g. `7.20rc5`)
- Converts raw images to `qcow2` format automatically
- Detects image format (raw/qcow2) and handles each correctly
- Colored, step-by-step terminal output
- Runs `fixpermissions` automatically
- `--dry-run` mode to preview actions without making changes
- Install from a **local file** (no download needed)

## Requirements

- **EVE-NG** (Community or Pro) — script runs on the EVE-NG server itself
- `bash`, `curl`, `unzip`, `qemu-img`
- Root privileges (`sudo`)

## Usage

### Install a CHR version

```bash
sudo ./chr-eve.sh install --version 7.20
sudo ./chr-eve.sh install --version 7.20rc5
sudo ./chr-eve.sh install --version 7.20 --force       # overwrite existing
sudo ./chr-eve.sh install --version 7.19.4 --local /tmp/chr-7.19.4.img  # from local file
sudo ./chr-eve.sh install --version 7.20 --dry-run     # preview only
sudo ./chr-eve.sh install --version 7.20 --name my-chr # custom directory name
```

| Flag | Description |
|------|-------------|
| `--version` | **(required)** RouterOS version — e.g. `7.20`, `7.11rc1`, `6.49.17` |
| `--local` | Path to a local `.img` file (skip download) |
| `--name` | Custom directory name under `/opt/unetlab/addons/qemu/` |
| `--force` | Overwrite if the version is already installed |
| `--dry-run` | Show what would happen without making changes |

### List installed CHR images

```bash
sudo ./chr-eve.sh list
```

### Remove a CHR version

```bash
sudo ./chr-eve.sh remove --version 7.19.4
sudo ./chr-eve.sh remove --name mikrotik-7.19.4   # by directory name
```

## Installation path

Images are placed in:

```
/opt/unetlab/addons/qemu/mikrotik-<version>/hda.qcow2
```

In EVE-NG, add a node of type **MikroTik** and select the installed version from the dropdown.

## Compatibility

| | Supported |
|---|-----------|
| EVE-NG | Community & Pro |
| RouterOS | v6.x and v7.x |
| Channels | stable, long-term, testing, RC, beta |
| Host OS | Ubuntu 20.04 / 22.04 (EVE-NG base) |

## Training Labs

The `Labs/` folder contains ready-to-use EVE-NG lab topologies for MikroTik training courses.

`CHR-EVE-slides.pdf` — presentation slides covering CHR deployment in EVE-NG.

## Related

- [MikroTik CHR Documentation](https://help.mikrotik.com/docs/spaces/ROS/pages/18350234/Cloud+Hosted+Router+CHR)
- [EVE-NG](https://www.eve-ng.net/)
- [RouterOS Downloads](https://mikrotik.com/download)

## Author

**Ihor Hreskiv** — MikroTik Certified Trainer

- [mtik.pl](https://mtik.pl) — MikroTik training (Poland, Kraków)
- [mtik.tech](https://mtik.tech) — MikroTik training (Ukraine, online)
- [YouTube PL](https://www.youtube.com/@mikrotikpolska) · [YouTube UA](https://www.youtube.com/@mikrotikukraine)
- [LinkedIn](https://www.linkedin.com/in/hreskiv) · [GitHub](https://github.com/hreskiv)

## License

This project is provided as-is. See [LICENSE](LICENSE) for details.

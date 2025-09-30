#!/usr/bin/env bash
# chr-eve.sh — Install/List/Remove MikroTik CHR images for EVE‑NG (CE/PRO)

set -euo pipefail
IFS=$'\n\t'

SCRIPT_NAME=$(basename "$0")
SUBCMD="install"     # default action: install | list | remove
VERSION=""
NAME=""
DRY_RUN=false
FORCE=false
LOCAL_SRC=""

EVE_ADDONS_DIR="/opt/unetlab/addons/qemu"
FIXPERM_WRAPPER="/opt/unetlab/wrappers/unl_wrapper"

# ---------- Colors ----------
if [[ -t 1 ]] && command -v tput >/dev/null 2>&1; then
  BOLD=$(tput bold); RESET=$(tput sgr0)
  C_BLUE=$(tput setaf 4); C_GREEN=$(tput setaf 2); C_YELLOW=$(tput setaf 3); C_RED=$(tput setaf 1)
else
  BOLD=""; RESET=""; C_BLUE=""; C_GREEN=""; C_YELLOW=""; C_RED=""
fi

step()   { printf "%s[→]%s %s\n" "$C_BLUE" "$RESET" "$*"; }
log()    { printf "%s[+]%s %s\n" "$C_GREEN" "$RESET" "$*"; }
warn()   { printf "%s[!]%s %s\n" "$C_YELLOW" "$RESET" "$*"; }
error()  { printf "%s[✗]%s %s\n" "$C_RED" "$RESET" "$*"; }
die()    { error "$*"; exit 1; }
need()   { command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"; }

usage() {
  cat <<EOF
${BOLD}$SCRIPT_NAME${RESET} — Manage MikroTik CHR images for EVE‑NG (no URL needed)

${BOLD}Usage:${RESET}
  $SCRIPT_NAME install --version <x.y[.z][rcN]> [--name <dir-name>] [--local <file>] [--force] [--dry-run]
  $SCRIPT_NAME list
  $SCRIPT_NAME remove --version <x.y[.z][rcN]>   # or --name <dir-name>

${BOLD}Examples:${RESET}
  $SCRIPT_NAME install --version 7.20
  $SCRIPT_NAME install --version 7.20rc5 --force
  $SCRIPT_NAME list
  $SCRIPT_NAME remove --version 7.19.4

${BOLD}Notes:${RESET}
  • Automatically downloads: https://download.mikrotik.com/routeros/<ver>/chr-<ver>.img.zip
  • Installs to: ${EVE_ADDONS_DIR}/mikrotik-<ver>/hda.qcow2
  • Requires: bash, curl, unzip, qemu-img, root
EOF
}

# ---------- Parse subcommand ----------
if [[ $# -gt 0 ]]; then
  case "$1" in
    install|list|remove) SUBCMD=$1; shift ;;
  esac
fi

# ---------- Common args ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) VERSION=${2:-}; shift 2 ;;
    --name)    NAME=${2:-}; shift 2 ;;
    --local)   LOCAL_SRC=${2:-}; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --force)   FORCE=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Unknown option: $1 (use --help)" ;;
  esac
done

run() {
  if $DRY_RUN; then
    echo "DRY-RUN: $*"
  else
    eval "$*"
  fi
}

qemu_format() {
  local f="$1"
  qemu-img info "$f" 2>/dev/null | awk -F': *' '/file format/ {print $2; exit}'
}

fix_permissions() {
  step "Fixing permissions"
  if $DRY_RUN; then
    echo "DRY-RUN: $FIXPERM_WRAPPER -a fixpermissions"
    return 0
  fi
  if [[ -x "$FIXPERM_WRAPPER" ]]; then
    "$FIXPERM_WRAPPER" -a fixpermissions || die "fixpermissions failed via unl_wrapper"
  else
    warn "unl_wrapper not found, applying fallback perms"
    chmod 755 "$EVE_ADDONS_DIR" || true
    chown -R root:root "$EVE_ADDONS_DIR" || true
    find "$EVE_ADDONS_DIR" -type d -exec chmod 755 {} + || true
    find "$EVE_ADDONS_DIR" -type f -exec chmod 644 {} + || true
  fi
}

# ---------- Subcommands ----------
case "$SUBCMD" in
  list)
    [[ -d "$EVE_ADDONS_DIR" ]] || die "EVE‑NG not detected: $EVE_ADDONS_DIR missing"
    step "Scanning installed MikroTik images in $EVE_ADDONS_DIR"
    found=false
    while IFS= read -r dir; do
      found=true
      ver=$(basename "$dir" | sed -E 's/^mikrotik-//')
      size=$(stat -c %s "$dir/hda.qcow2" 2>/dev/null || echo 0)
      if [[ "$size" -gt 0 ]]; then
        log "${BOLD}${ver}${RESET} — hda.qcow2 present (${size} bytes)"
      else
        warn "${BOLD}${ver}${RESET} — hda.qcow2 missing"
      fi
    done < <(find "$EVE_ADDONS_DIR" -maxdepth 1 -type d -name 'mikrotik-*' | sort)
    $found || warn "No mikrotik-* directories found"
    exit 0
    ;;

  remove)
    [[ -d "$EVE_ADDONS_DIR" ]] || die "EVE‑NG not detected: $EVE_ADDONS_DIR missing"
    target_name="${NAME:-${VERSION}}"
    [[ -n "$target_name" ]] || die "Specify --version or --name for remove"
    TARGET_DIR="$EVE_ADDONS_DIR/mikrotik-$target_name"
    [[ -e "$TARGET_DIR" ]] || die "Not found: $TARGET_DIR"
    step "Removing $TARGET_DIR"
    run "rm -rf '$TARGET_DIR'"
    fix_permissions
    log "Removed mikrotik-$target_name"
    exit 0
    ;;

  install)
    [[ $EUID -eq 0 ]] || die "Run as root (sudo)."
    [[ -d "$EVE_ADDONS_DIR" ]] || die "EVE‑NG not detected: $EVE_ADDONS_DIR missing"
    need qemu-img; need curl; need unzip

    [[ -n "$VERSION" ]] || { usage; die "--version is required for install"; }
    if ! [[ "$VERSION" =~ ^[0-9]+(\.[0-9]+){0,2}(rc[0-9]+)?$ ]]; then
      die "Version must look like '7.20' or '7.20rc5'"
    fi

    TARGET_DIR_NAME="mikrotik-${NAME:-$VERSION}"
    TARGET_DIR="$EVE_ADDONS_DIR/$TARGET_DIR_NAME"
    TARGET_DISK="$TARGET_DIR/hda.qcow2"

    CDN_URL="https://download.mikrotik.com/routeros/${VERSION}/chr-${VERSION}.img.zip"

    step "Preparing workspace"
    WORKDIR=$(mktemp -d); trap 'rm -rf "$WORKDIR"' EXIT
    SRC_LOCAL="$WORKDIR/src.img"; ZIP_PATH="$WORKDIR/chr-${VERSION}.img.zip"

    if [[ -n "$LOCAL_SRC" ]]; then
      step "Using local source: $LOCAL_SRC"
      run "cp -f '$LOCAL_SRC' '$SRC_LOCAL'"
    else
      step "Downloading CHR ${VERSION}"
      log "$CDN_URL"
      run "curl -fsSL --retry 3 --retry-delay 2 -o '$ZIP_PATH' '$CDN_URL'"
      step "Unzipping image"
      run "unzip -p '$ZIP_PATH' > '$SRC_LOCAL'"
    fi

    if [[ -e "$TARGET_DIR" ]]; then
      if $FORCE; then
        step "Removing existing $TARGET_DIR (force)"
        run "rm -rf '$TARGET_DIR'"
      else
        die "Target exists: $TARGET_DIR (use --force)"
      fi
    fi

    step "Creating target directory $TARGET_DIR"
    run "mkdir -p '$TARGET_DIR'"

    step "Detecting image format"
    FORMAT=$(qemu_format "$SRC_LOCAL" || true)
    if [[ "$FORMAT" == "qcow2" ]]; then
      log "Source is qcow2 — copying as hda.qcow2"
      run "cp -f '$SRC_LOCAL' '$TARGET_DISK'"
    elif [[ "$FORMAT" == "raw" || -z "$FORMAT" ]]; then
      step "Converting RAW → QCOW2"
      run "qemu-img convert -p -f raw -O qcow2 '$SRC_LOCAL' '$TARGET_DISK'"
    else
      step "Converting $FORMAT → QCOW2"
      run "qemu-img convert -p -O qcow2 '$SRC_LOCAL' '$TARGET_DISK'"
    fi

    fix_permissions
    log "Done. Installed: $TARGET_DISK"
    log "Add node in EVE‑NG: type 'mikrotik' -> $TARGET_DIR_NAME"
    ;;

  *)
    usage; exit 1 ;;

esac


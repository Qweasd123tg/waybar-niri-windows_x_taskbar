#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$ROOT_DIR/dist"
WAYBAR_DIR="$HOME/.config/waybar"
BACKUP_DIR="$WAYBAR_DIR/backups"
RESTART=0
INSTALL_TASKBAR=0

for arg in "$@"; do
  case "$arg" in
    --restart-waybar)
      RESTART=1
      ;;
    --with-taskbar)
      INSTALL_TASKBAR=1
      ;;
    *)
      echo "unknown option: $arg" >&2
      echo "usage: $0 [--restart-waybar] [--with-taskbar]" >&2
      exit 1
      ;;
  esac
done

mkdir -p "$WAYBAR_DIR" "$BACKUP_DIR"

if [[ ! -f "$DIST_DIR/waybar-niri-windows.so" ]]; then
  "$ROOT_DIR/build.sh" windows
fi

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

backup_if_exists() {
  local source_path="$1"
  if [[ -f "$source_path" ]]; then
    cp "$source_path" "$BACKUP_DIR/${TIMESTAMP}_$(basename "$source_path")"
  fi
}

backup_if_exists "$WAYBAR_DIR/waybar-niri-windows.so"
install -m 755 \
  "$DIST_DIR/waybar-niri-windows.so" \
  "$WAYBAR_DIR/waybar-niri-windows.so"

if (( INSTALL_TASKBAR )) && [[ -f "$DIST_DIR/libniri_taskbar.so" ]]; then
  backup_if_exists "$WAYBAR_DIR/libniri_taskbar.so"
  install -m 755 \
    "$DIST_DIR/libniri_taskbar.so" \
    "$WAYBAR_DIR/libniri_taskbar.so"
fi

echo "installed:"
echo "  $WAYBAR_DIR/waybar-niri-windows.so"

if (( INSTALL_TASKBAR )) && [[ -f "$DIST_DIR/libniri_taskbar.so" ]]; then
  echo "  $WAYBAR_DIR/libniri_taskbar.so"
fi

if (( RESTART )); then
  pkill -x waybar || true
  setsid -f waybar >/tmp/waybar-test.log 2>&1
  echo "waybar restarted"
fi

cat <<EOF

Waybar config can point either to:

  $DIST_DIR/waybar-niri-windows.so
  $DIST_DIR/libniri_taskbar.so  (only if you use --with-taskbar)

or to installed copies:

  $WAYBAR_DIR/waybar-niri-windows.so
  $WAYBAR_DIR/libniri_taskbar.so  (only if you use --with-taskbar)
EOF

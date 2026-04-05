#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="$ROOT_DIR/dist"
CACHE_DIR="$ROOT_DIR/.cache"
UPSTREAMS_DIR="$CACHE_DIR/upstreams"
BUILD_SRC_DIR="$CACHE_DIR/build-src"

WAYBAR_WINDOWS_REPO="https://github.com/calico32/waybar-niri-windows"
WAYBAR_WINDOWS_COMMIT="c0cfe95ee63c19636ba96567c21d87ee0b7eb93f"
NIRI_TASKBAR_REPO="https://github.com/lawngnome/niri-taskbar"
NIRI_TASKBAR_COMMIT="c530349fae638141ec58a9d4db0816d950a9295a"

usage() {
  cat <<'EOF'
Usage:
  ./build.sh            # build all
  ./build.sh windows    # build only waybar-niri-windows
  ./build.sh taskbar    # build only niri-taskbar
EOF
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "missing command: $1" >&2
    exit 1
  fi
}

ensure_repo() {
  local url="$1"
  local commit="$2"
  local repo_dir="$3"

  need_cmd git

  if [[ ! -d "$repo_dir/.git" ]]; then
    git clone "$url" "$repo_dir"
  fi

  git -C "$repo_dir" fetch --tags origin
  git -C "$repo_dir" checkout --detach "$commit"
}

export_repo_at_commit() {
  local repo_dir="$1"
  local commit="$2"
  local target_dir="$3"

  rm -rf "$target_dir"
  mkdir -p "$target_dir"

  (
    cd "$repo_dir"
    git archive "$commit"
  ) | tar -x -C "$target_dir"
}

prepare_windows_source() {
  local repo_dir="$UPSTREAMS_DIR/waybar-niri-windows"
  local src_dir="$BUILD_SRC_DIR/waybar-niri-windows"

  ensure_repo "$WAYBAR_WINDOWS_REPO" "$WAYBAR_WINDOWS_COMMIT" "$repo_dir"
  export_repo_at_commit "$repo_dir" "$WAYBAR_WINDOWS_COMMIT" "$src_dir"

  git -C "$src_dir" init -q
  git -C "$src_dir" apply "$ROOT_DIR/patches/waybar-niri-windows.patch"

  printf '%s\n' "$src_dir"
}

prepare_taskbar_source() {
  local repo_dir="$UPSTREAMS_DIR/niri-taskbar"
  local src_dir="$BUILD_SRC_DIR/niri-taskbar"

  ensure_repo "$NIRI_TASKBAR_REPO" "$NIRI_TASKBAR_COMMIT" "$repo_dir"
  export_repo_at_commit "$repo_dir" "$NIRI_TASKBAR_COMMIT" "$src_dir"

  printf '%s\n' "$src_dir"
}

build_windows() {
  local src_dir

  need_cmd go
  need_cmd pkg-config
  pkg-config --exists gtk+-3.0 gio-unix-2.0

  mkdir -p \
    "$DIST_DIR" \
    "$CACHE_DIR/go" \
    "$CACHE_DIR/go-build" \
    "$UPSTREAMS_DIR" \
    "$BUILD_SRC_DIR"

  src_dir="$(prepare_windows_source)"

  (
    cd "$src_dir"
    env \
      GOPATH="$CACHE_DIR/go" \
      GOMODCACHE="$CACHE_DIR/go/pkg/mod" \
      GOCACHE="$CACHE_DIR/go-build" \
      go build -buildmode=c-shared -o "$DIST_DIR/waybar-niri-windows.so" ./main
  )

  echo "built: $DIST_DIR/waybar-niri-windows.so"
}

build_taskbar() {
  local src_dir

  need_cmd cargo
  need_cmd pkg-config
  pkg-config --exists gtk+-3.0

  mkdir -p \
    "$DIST_DIR" \
    "$CACHE_DIR/cargo" \
    "$CACHE_DIR/cargo-target" \
    "$UPSTREAMS_DIR" \
    "$BUILD_SRC_DIR"

  src_dir="$(prepare_taskbar_source)"

  (
    cd "$src_dir"
    env \
      CARGO_HOME="$CACHE_DIR/cargo" \
      CARGO_TARGET_DIR="$CACHE_DIR/cargo-target" \
      cargo build --release --locked
  )

  install -m 755 \
    "$CACHE_DIR/cargo-target/release/libniri_taskbar.so" \
    "$DIST_DIR/libniri_taskbar.so"

  echo "built: $DIST_DIR/libniri_taskbar.so"
}

case "${1:-all}" in
  all)
    build_windows
    build_taskbar
    ;;
  windows)
    build_windows
    ;;
  taskbar)
    build_taskbar
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac

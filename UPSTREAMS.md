# Upstream Sources

This repository does not commit vendored upstream source trees.

Instead, [`build.sh`](build.sh) fetches these pinned upstream revisions and applies the local patch set from [`patches/`](patches/):

- `calico32/waybar-niri-windows`
  - repository: https://github.com/calico32/waybar-niri-windows
  - pinned commit: `c0cfe95ee63c19636ba96567c21d87ee0b7eb93f`
  - local patch: [`patches/waybar-niri-windows.patch`](patches/waybar-niri-windows.patch)

- `LawnGnome/niri-taskbar`
  - repository: https://github.com/lawngnome/niri-taskbar
  - pinned commit: `c530349fae638141ec58a9d4db0816d950a9295a`
  - local patch: none

# waybar-niri-windows_x_taskbar

Hybrid Waybar module for [niri](https://github.com/YaLTeR/niri): a window minimap based on `cffi/niri-windows`, extended with automatic app icon rendering, all-workspaces minimap mode, and local build/install scripts.

## Attribution

This repository is built on top of:

- [`calico32/waybar-niri-windows`](https://github.com/calico32/waybar-niri-windows) for the original niri window minimap / Waybar CFFI module foundation
- [`LawnGnome/niri-taskbar`](https://github.com/lawngnome/niri-taskbar) for taskbar-style app icon lookup ideas and desktop entry icon resolution

Local changes in this repository add:

- application icon rendering inside minimap tiles
- generic fallback icons for apps without a resolved desktop icon
- multi-workspace minimap mode via `"workspace-scope": "all"`
- local `build.sh` and `install.sh` workflow
- packaging that keeps build caches inside the repository directory

Upstream sources are fetched during build from pinned commits listed in [`UPSTREAMS.md`](UPSTREAMS.md).

## Repository Layout

- [`build.sh`](build.sh) - builds `.so` artifacts into local `dist/`
- [`install.sh`](install.sh) - installs built libraries into `~/.config/waybar/`
- [`examples/waybar-snippet.jsonc`](examples/waybar-snippet.jsonc) - minimal Waybar config snippet
- [`NOTICE`](NOTICE) - provenance and upstream credit summary
- [`UPSTREAMS.md`](UPSTREAMS.md) - pinned upstream repositories and commits
- [`patches/`](patches/) - local patch set applied during build

## Features

- graphical minimap for niri windows in Waybar
- app icons rendered inside tiles
- fallback to a generic executable icon when app-specific icons are missing
- all-workspaces minimap mode inside a single module
- optional standalone `cffi/niri-taskbar` alongside the hybrid minimap

## Requirements

- `niri >= 25.08`
- `waybar` with CFFI module support
- `git`
- For `waybar-niri-windows` builds:
  - `go`
  - `pkg-config`
  - GTK 3 development headers
  - `gio-unix-2.0`
- For `niri-taskbar` builds:
  - `cargo`
  - `rustc`
  - GTK 3 development headers

## Build

Build both modules:

```bash
./build.sh
```

Build only the minimap module:

```bash
./build.sh windows
```

Build only the taskbar:

```bash
./build.sh taskbar
```

Artifacts are written to:

- `dist/waybar-niri-windows.so`
- `dist/libniri_taskbar.so`

Build caches stay local to the repository:

- `.cache/go/`
- `.cache/go-build/`
- `.cache/cargo/`
- `.cache/cargo-target/`

During build, upstream sources are fetched from their original repositories and patched locally. No vendored upstream source trees are committed to this repository.

## Install

Install built modules into `~/.config/waybar/`:

```bash
./install.sh
```

Install and restart Waybar:

```bash
./install.sh --restart-waybar
```

The installer creates backups in `~/.config/waybar/backups/`.

## Waybar Configuration

Minimal example: [`examples/waybar-snippet.jsonc`](examples/waybar-snippet.jsonc)

Important options:

```jsonc
"icon-minimum-size": 1,
"workspace-scope": "all"
```

- `"icon-minimum-size": 1` allows icons to render in very small tiles
- `"workspace-scope": "all"` shows all workspaces as separate minimaps inside one module

You can either point Waybar directly to the local build artifacts:

```jsonc
"module_path": "/path/to/repo/dist/waybar-niri-windows.so"
```

or to installed copies in `~/.config/waybar/`:

```jsonc
"module_path": "~/.config/waybar/waybar-niri-windows.so"
```

## Notes

- The hybrid icon logic means `cffi/niri-taskbar` is no longer required for icons inside `cffi/niri-windows`.
- The standalone `cffi/niri-taskbar` can still be kept if you want a separate row of app icons next to the minimap.
- If you move this repository, update `module_path` in your Waybar config.

## License

This repository is distributed under the MIT License. See [`LICENSE`](LICENSE).

Upstream origins and pinned revisions are documented in [`UPSTREAMS.md`](UPSTREAMS.md).

Original upstream MIT license texts are preserved in:

- [`licenses/waybar-niri-windows.MIT`](licenses/waybar-niri-windows.MIT)
- [`licenses/niri-taskbar.MIT`](licenses/niri-taskbar.MIT)

# OBS SnekStudio Source

This repository contains a cooperative OBS Studio capture workflow for
SnekStudio on Linux Wayland.

The original goal was generic Wayland per-window capture for OBS. After a short
spike, that path was shown to be blocked by the active portal backend in the
target environment, so the project pivoted to a SnekStudio-specific cooperative
capture path instead.

Today, this repository contains three related deliverables:

- an OBS source plugin that reads frames from a shared framebuffer file,
- a SnekStudio runtime mod that publishes those frames,
- an Asset Library package for the SnekStudio-side mod.

## Status

Current state:

- The OBS source plugin builds locally and works with the shared-frame protocol.
- The `OBSFramePublisher` SnekStudio mod can publish frames that the OBS source
  displays.
- The mod supports fixed-resolution output and a publish FPS cap for better
  stability and performance.
- A self-contained Godot Asset Library package for the mod exists under
  `assetlib/`.

Still open:

- More runtime stability testing around resize, hide, and invalidation paths.
- Packaging and release hardening beyond the current local and draft package
  flows.

## Repository Layout

- `src/`
  OBS plugin source code.
- `include/`
  Shared frame protocol headers used by the plugin and publisher.
- `scripts/`
  Helper scripts for launching, probing, and building support artifacts.
- `snekstudio-mods/`
  External SnekStudio mod sources kept outside the cloned upstream SnekStudio
  tree.
- `assetlib/`
  Self-contained Godot Asset Library package for the `OBSFramePublisher` mod.
- `packaging/`
  Packaging work for Arch, Debian, and Nix.
- `drafts/`
  Early implementation drafts and design notes.
- `SnekStudio/`
  A local upstream clone used for compatibility testing. Treat this as upstream
  code, not as the primary home for the shipped mod.

## Quick Start

### 1. Build the OBS plugin

```bash
cmake -S . -B build
cmake --build build
```

This produces the OBS module `snekstudio-source` in the build tree.

### 2. Launch SnekStudio with the external mod

From source checkout:

```bash
bash scripts/run_snekstudio_with_external_mods.sh --source
```

Using the system-wide `snekstudio` binary:

```bash
bash scripts/run_snekstudio_with_external_mods.sh --system
```

Both flows build `dist/snekstudio-mods/OBSFramePublisher.zip`, prepend that
directory to `SNEKSTUDIO_MODS_PATHS`, and launch SnekStudio.

### 3. Add the SnekStudio mod

Inside SnekStudio:

1. Open `Mods -> Mod List`.
2. Add `OBSFramePublisher`.
3. Configure the output path, output mode, and target publish FPS if needed.

Default shared-frame path:

```text
$XDG_RUNTIME_DIR/snekstudio-source/demo-framebuffer.bin
```

### 4. Add the OBS source

Inside OBS Studio:

1. Add the custom source `SnekStudio Source (MVP)`.
2. Point it at the shared-frame path if you changed the mod default.
3. Confirm frames appear.

## SnekStudio Mod Strategy

The SnekStudio-side mod is intentionally maintained outside the cloned upstream
SnekStudio repository.

Why:

- it keeps local feature work separate from upstream code,
- it makes the mod loadable through `SNEKSTUDIO_MODS_PATHS`,
- it matches the eventual distribution model more closely.

The primary external mod sources live under:

- `snekstudio-mods/OBSFramePublisher/`

## Asset Library Package

The Godot Asset Library-oriented package lives under:

- `assetlib/SnekStudioOBSFramePublisher/`

That directory contains:

- the mod files,
- package-specific `README.md` and `LICENSE.md`,
- a square icon,
- preview images,
- submission notes.

If you want to publish the mod to the official Godot Asset Library, treat that
directory as the root of a dedicated repository or subtree.

## Documentation

- `SPEC.md`
  Project scope and architecture direction.
- `PHASE1.md`
  Generic Wayland capture spike findings and why the project pivoted.
- `MVP.md`
  MVP implementation notes.
- `tasks.md`
  Current tracked work.

## Packaging

The repository includes draft or working packaging support for:

- Arch Linux,
- Debian,
- Nix.

See `packaging/` for details.

## License

This repository is distributed under the GNU GPL v3.0 or later. See `LICENSE`.
# SnekStudio OBSFramePublisher

SnekStudio OBSFramePublisher is a SnekStudio runtime mod for Godot 4.6. It publishes the rendered SnekStudio viewport to the shared framebuffer consumed by the companion OBS source plugin.

This asset is intended for SnekStudio projects. It depends on SnekStudio's existing runtime mod API and is not a standalone generic Godot addon.

## Requirements

- Godot 4.6
- A SnekStudio project checkout
- Linux for the tested shared-frame workflow
- The companion OBS source plugin if you want to display the published frames in OBS Studio

## Installation

Install this asset into the root of a SnekStudio project.

This asset intentionally installs files into `Mods/OBSFramePublisher/` instead of `addons/...`. That is a deliberate exception to the usual Asset Library recommendation, because SnekStudio discovers runtime mods from `res://Mods`. Keeping the mod in `Mods/` makes the asset work immediately after installation inside a SnekStudio project.

After installation:

1. Open the SnekStudio project in Godot 4.6.
2. Run the project.
3. Open `Mods -> Mod List`.
4. Add `OBSFramePublisher`.
5. Configure the output path, resolution mode, and target publish FPS as needed.

## Features

- Publishes the final SnekStudio viewport to a shared frame file.
- Supports fixed-resolution output for a stable OBS source size.
- Supports a configurable publish FPS cap to reduce viewport readback cost.
- Writes RGBA8 frames directly so the GDScript hot path avoids an extra swizzle pass.

## Notes

- The root viewport is captured, so visible SnekStudio UI may appear in the output.
- The default output path is `$XDG_RUNTIME_DIR/snekstudio-source/demo-framebuffer.bin`.
- This asset is intended for SnekStudio projects and does not modify SnekStudio engine code.
- The companion OBS source plugin is distributed separately from this Asset Library package.

## License

This asset is distributed under the GNU GPL v3.0 or later. See `LICENSE.md`.

# Submission Notes

## Recommended Asset Library Fields

- Asset name: `SnekStudio OBSFramePublisher`
- Asset type: `Addon`
- Godot version: `4.6`
- License: `GPL 3.0 or later`
- Repository: use this folder as the root of a dedicated repository or subtree
- Icon file: `meta/icon.png`

## Description Draft

SnekStudio OBSFramePublisher is a SnekStudio runtime mod for Godot 4.6. It publishes the rendered SnekStudio viewport to the shared framebuffer consumed by the companion OBS source plugin. The mod supports fixed-resolution output and a configurable publish FPS cap to balance stability and performance.

## Important Packaging Note

This asset intentionally installs into `Mods/OBSFramePublisher/` instead of `addons/...` because SnekStudio discovers runtime mods from `res://Mods`. This is a deliberate compatibility choice so the asset works immediately when installed into a SnekStudio project.

## Suggested Icon URL Pattern

If you publish this folder as its own GitHub repository, the icon URL should look like:

`https://raw.githubusercontent.com/<owner>/<repo>/<branch>/meta/icon.png`

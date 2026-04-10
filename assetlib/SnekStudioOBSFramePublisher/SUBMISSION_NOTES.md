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

## Compliance Pass

Items checked against the stable Asset Library submission guide:

- Requirement met: root `.gitignore` exists.
- Requirement met: root `LICENSE.md` exists and includes a copyright statement plus license text.
- Requirement met: package contains no essential submodules.
- Requirement met: icon is a direct package asset and is a square PNG larger than 128x128.
- Recommendation met: `.gitattributes` exists.
- Recommendation met: preview images are kept in their own folder with a `.gdignore` file.
- Recommendation met: the plugin folder contains copies of the README and license.
- Recommendation met: descriptions are written in English with full sentences.

Important caveat to communicate in the submission text:

- This is a SnekStudio-specific runtime mod, not a generic standalone Godot addon. It is expected to be installed into a SnekStudio project checkout.
- The asset uses `Mods/OBSFramePublisher/` instead of `addons/...` for SnekStudio compatibility. This is a deliberate exception to the usual addon layout recommendation.

## Suggested Icon URL Pattern

If you publish this folder as its own GitHub repository, the icon URL should look like:

`https://raw.githubusercontent.com/<owner>/<repo>/<branch>/meta/icon.png`

# SnekStudio Module PR Notes

## Current Prototype

An initial in-tree SnekStudio mod now exists in the local SnekStudio clone at:

- `SnekStudio/Mods/OBSFramePublisher/OBSFramePublisher.gd`
- `SnekStudio/Mods/OBSFramePublisher/OBSFramePublisher.tscn`
- `SnekStudio/Mods/OBSFramePublisher/description.txt`

This started as a fastest-path MVP, but it now has the minimum shape needed to
be argued upstream as a reasonable first implementation.

## Why Start With A GDScript Mod

- It fits SnekStudio's existing mod system directly.
- It avoids introducing a native build chain into the first PR.
- It is easier for upstream review because the implementation stays in the same language and extension model already used by many SnekStudio mods.
- It is enough to validate whether the OBS-side shared-frame protocol is viable from the real application.

## Why Capture The Root Viewport

- It is the fastest surface to reach from GDScript.
- It avoids digging through more specialized rendering paths before proving the overall integration.
- It captures the final composited output, which is what OBS most likely wants for the MVP.

## Current Behavior Contract

- The mod captures the root viewport every frame.
- It converts the captured image from RGBA8 to BGRA8 on the CPU.
- It writes the existing shared-frame header and payload layout expected by the OBS plugin.
- It publishes by default to `$XDG_RUNTIME_DIR/snekstudio-source/demo-framebuffer.bin`, matching the OBS plugin default.
- It supports a fixed-resolution publishing mode so the OBS source size can stay stable.
- The UI surface is still intentionally minimal: enable toggle, output path, and output resolution controls.

## Known Limitations

- This path performs a GPU-to-CPU image readback every frame.
- It also performs a CPU-side byte swizzle from RGBA to BGRA every frame.
- If the SnekStudio UI is visible, it may appear in the captured frame because the current prototype captures the root viewport.
- The current validation is functional and local, but not yet a full runtime performance study.

## When To Pivot Away From GDScript

If runtime testing shows unacceptable latency, stalls, or frame drops, the next options should be evaluated in this order:

1. A narrower capture surface inside Godot that avoids unnecessary UI capture.
2. A native Godot extension for a faster frame extraction path.
3. An external helper only if the in-tree mod path is clearly insufficient.

The external helper should be treated as a fallback, not the first choice, because the GDScript mod is much easier to justify upstream.

## Suggested Upstream PR Framing

- This PR adds an optional OBS integration module for cooperative capture.
- It does not change SnekStudio's normal rendering path unless the mod is enabled.
- It reuses an already-defined shared-frame protocol and an existing OBS-side reader.
- It deliberately starts with a simple implementation to validate usefulness before any native optimization work.
- If upstream wants a stricter performance bar, this MVP can be used as the baseline for deciding whether a native follow-up is warranted.

## Suggested Change Split

For upstream submission, the current local work should be split into two reviewable patches:

1. `OBSFramePublisher` mod and its description file.
2. Linux camera enumeration fallback in `Mods/MediaPipe/_tracker/Project/new_tracker.py`.

That keeps the OBS integration review separate from the unrelated MediaPipe device-detection fix.
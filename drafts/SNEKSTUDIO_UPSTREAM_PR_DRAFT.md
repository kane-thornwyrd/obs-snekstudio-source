# SnekStudio Upstream PR Draft

## Recommended Split

The local SnekStudio-side work is in a better state for upstream review if it is submitted as two separate PRs.

### PR 1

Title:

`Add OBSFramePublisher mod for cooperative OBS capture`

Files:

- `Mods/OBSFramePublisher/OBSFramePublisher.gd`
- `Mods/OBSFramePublisher/OBSFramePublisher.tscn`
- `Mods/OBSFramePublisher/description.txt`

Suggested body:

This PR adds an optional `OBSFramePublisher` mod that publishes the final SnekStudio viewport to a shared framebuffer file for the companion OBS source plugin.

Why this shape:

- It stays inside SnekStudio's existing mod system.
- It keeps the first implementation in GDScript, which is easier to review and maintain than a native extension.
- It does not change SnekStudio's normal render path unless the mod is enabled.
- It now supports a fixed-resolution publishing mode so the OBS source size can remain stable.

Current behavior:

- Captures the root viewport each frame.
- Converts RGBA8 to BGRA8 on the CPU.
- Writes the existing shared-frame header and payload format already consumed by the OBS plugin.
- Defaults to `$XDG_RUNTIME_DIR/snekstudio-source/demo-framebuffer.bin`.
- Can either publish the live viewport size or a fixed output resolution.

Known limitations:

- This still performs a GPU-to-CPU image readback each frame.
- The root viewport capture may include visible SnekStudio UI.
- The implementation prioritizes clarity and low integration cost over absolute performance.

Manual test notes:

1. Launch SnekStudio from source.
2. Add the `OBSFramePublisher` mod.
3. Start the OBS companion source pointing at the default shared framebuffer path.
4. Confirm live frame updates.
5. Confirm shutdown invalidates the stream cleanly.
6. Confirm fixed-resolution mode keeps the OBS source size stable.

### PR 2

Title:

`Add Linux /dev/video fallback for MediaPipe camera enumeration`

Files:

- `Mods/MediaPipe/_tracker/Project/new_tracker.py`

Suggested body:

This PR adds a Linux fallback for camera enumeration in the MediaPipe tracker path. If the OpenCV enumeration helper returns no camera devices, the tracker now falls back to scanning `/dev/video*` and exposes those devices as V4L2 camera entries.

Why this should be separate:

- It is logically independent from the OBS publisher mod.
- It touches existing MediaPipe tracker behavior and deserves its own focused review.
- It makes regression analysis easier if any camera-detection issue appears later.

Manual test notes:

1. Launch SnekStudio on Linux with V4L2 camera devices present.
2. Open the MediaPipe mod settings.
3. Confirm camera devices appear even when the OpenCV helper enumerator returns nothing.
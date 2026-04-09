# SnekStudio OBS Source MVP

This repository now contains a cooperative capture MVP for SnekStudio-specific OBS integration.

What is included:

- A real OBS input source plugin built against `libobs`.
- A stable shared-memory frame protocol in `include/snekstudio_frame_protocol.h`.
- A standalone publisher script in `scripts/snekstudio_demo_publisher.py` that simulates the future SnekStudio-side module.
- A source properties status panel that shows connection state, frame counters, and cached-frame state for debugging.

What is not included yet:

- A real SnekStudio integration module.
- Final packaging for Arch.
- Polished reconnect UX and richer source status UI inside OBS.

## Build

```bash
cmake -S . -B build
cmake --build build
```

To stage the plugin files without writing into `/usr`:

```bash
cmake --install build --prefix "$PWD/stage"
```

That produces:

- `stage/lib/obs-plugins/snekstudio-source.so`
- `stage/bin/snekstudio-demo-publisher`
- `stage/include/snekstudio-source/snekstudio_frame_protocol.h`
- `stage/share/obs/obs-plugins/snekstudio-source/snekstudio_frame_protocol.h`
- `stage/share/doc/obs-snekstudio-source/MVP.md`
- `stage/share/doc/obs-snekstudio-source/SPEC.md`

## Demo Flow

Start the demo publisher:

```bash
python scripts/snekstudio_demo_publisher.py
```

If you installed the staged or packaged build, the same publisher is available as:

```bash
snekstudio-demo-publisher
```

By default it writes frames to:

```text
$XDG_RUNTIME_DIR/snekstudio-source/demo-framebuffer.bin
```

Then in OBS:

1. Add a new input source named `SnekStudio Source (MVP)`.
2. Leave the default frame path as-is, or point it at a different shared frame file.
3. The source will reconnect automatically when the frame file becomes available.
4. Open the source properties to inspect the built-in status panel if you need connection or frame diagnostics.

## Protocol Notes

The MVP protocol is intentionally narrow:

- One producer writes a single BGRA8 frame buffer.
- One OBS source reads it.
- The header uses an even/odd write sequence so the reader can avoid torn copies.

The next step is to replace the demo publisher with a real SnekStudio-side module that writes the same header and pixel buffer layout.
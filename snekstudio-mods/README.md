# External SnekStudio Mods

This directory contains custom SnekStudio mods that are intentionally kept
outside the cloned SnekStudio repository.

The current `OBSFramePublisher` mod is packaged as a zip with internal
`Mods/...` paths so SnekStudio can load it through `SNEKSTUDIO_MODS_PATHS`
without modifying upstream source files.

Typical workflow:

```bash
bash scripts/run_snekstudio_with_external_mods.sh
```

That wrapper builds `dist/snekstudio-mods/OBSFramePublisher.zip`, prepends that
directory to `SNEKSTUDIO_MODS_PATHS`, and launches the cloned SnekStudio
project from source.

If you want to use an installed system-wide build instead, use:

```bash
bash scripts/run_snekstudio_with_external_mods.sh --system
```

That uses the same external mod zip and launches the `snekstudio` executable
found on `PATH`. You can override the binary with `SNEKSTUDIO_EXECUTABLE`.
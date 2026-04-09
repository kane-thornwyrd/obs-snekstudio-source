# Phase 1 Report

## Goal

Determine whether the fastest path to Wayland per-window capture in OBS is:

1. A generic PipeWire plus portal workflow.
2. A custom OBS plugin or source.

## Findings

### 1. OBS already has a built-in generic PipeWire capture path

Your installed OBS package already ships the `linux-pipewire` plugin and its locale strings confirm support for:

- `Screen Capture (PipeWire)`
- `Window Capture (PipeWire)`
- `Select Window`

Upstream OBS 32.1.1 `screencast-portal.c` confirms that the linux-pipewire integration already:

- Uses `xdg-desktop-portal` ScreenCast.
- Supports monitor and window capture types.
- Stores a `RestoreToken` when the portal version is `>= 4`.
- Exposes a reload button that reopens the selector.

This means the shortest generic path is not a new plugin. It is the existing OBS PipeWire capture flow.

### 2. `pipewire-capture` is useful for a fast spike, but not as an OBS source by itself

The `pipewire-capture` library installs cleanly in a local virtual environment and reports availability on this machine.

Its example flow is:

1. Open a portal window picker.
2. Receive PipeWire stream information.
3. Start a capture stream.
4. Read BGRA frames until the window becomes invalid.

That makes it a good prototype tool for validating capture behavior. It does not by itself create an OBS source. If we want to display those frames inside OBS without using OBS's built-in PipeWire source, we would still need either:

- A custom OBS source plugin.
- An intermediary device or transport that OBS already knows how to ingest.

### 3. The current blocker is the local portal backend, not missing OBS functionality

Local runtime checks show:

- `XDG_SESSION_TYPE=wayland`
- `XDG_CURRENT_DESKTOP=niri`
- `org.freedesktop.portal.ScreenCast version = 5`
- `AvailableSourceTypes = 0`
- `AvailableCursorModes = 0`

That means the live ScreenCast portal currently advertises no capturable source types at all.

Additional local evidence:

- `xdg-desktop-portal.service` is running.
- `xdg-desktop-portal-gtk.service` is active.
- `xdg-desktop-portal-gnome.service` is installed but inactive.
- The user Niri portal config prefers `gnome` for the session, but the live portal interface is still exposing no ScreenCast sources.

In practice, this is a hard blocker for any generic Wayland window capture path that relies on the standard ScreenCast portal, including OBS's built-in PipeWire source and any custom code that uses the same portal.

### 4. A custom OBS plugin is not the right pivot yet

For arbitrary Wayland window capture, a custom OBS plugin does not remove the fundamental portal or compositor constraint. It would still need a capture backend that can legally and reliably obtain the target window under Wayland.

The plugin fallback only becomes compelling if one of these is true:

- We need custom OBS UX after the generic portal flow is working.
- The target application can cooperate directly, for example by exporting frames or exposing a transport that does not depend on generic window capture.

## Decision

Continue with the generic path.

Do not pivot to a custom OBS source yet.

Reason:

- OBS already contains the generic PipeWire plus portal capture implementation we need.
- The current failure mode is environmental: the live ScreenCast portal is exposing zero sources in the Niri session.
- A custom plugin would not solve that root problem for generic arbitrary-window capture.

## Immediate Next Step

Before Phase 2A can meaningfully proceed, the Wayland portal backend must expose real ScreenCast source types in the active Niri session.

The next validation target is:

- `AvailableSourceTypes` should include window capture support instead of `0`.

Once that is true, test this order:

1. OBS built-in `Screen Capture (PipeWire)` source.
2. Confirm window selection works and persists acceptably.
3. Reassess whether any custom OBS source is still necessary.

## Reproducible Probe

Use the probe script in `scripts/phase1_portal_probe.py` to re-check the local environment.

Suggested commands:

```bash
python -m venv .venv
. .venv/bin/activate
python -m pip install pipewire-capture
python scripts/phase1_portal_probe.py
python scripts/phase1_portal_probe.py --select-window
```

The `--select-window` mode is interactive and only makes sense after the ScreenCast portal is actually advertising capture sources.

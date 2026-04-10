# Tasks

## Phase 1: Discovery And Decision

- [x] Verify the shortest generic path using PipeWire plus `xdg-desktop-portal`.
- [x] Confirm whether the generic path can feed OBS directly or needs a custom OBS integration layer.
- [x] Record compositor-specific constraints observed during the spike.
- [x] Decide whether to continue with the generic path or pivot to a custom OBS source.

## Phase 1 Outcome

- [x] Decision: continue with the generic path.
- [x] Immediate blocker identified: the active ScreenCast portal currently exposes `AvailableSourceTypes = 0` in the Niri session.
- [x] Reproducible local probe added in `scripts/phase1_portal_probe.py`.

## Pivot

- [x] Reassess the generic plan after confirming the portal blocker is environmental rather than missing OBS functionality.
- [x] Decide to build a SnekStudio-specific cooperative source MVP instead of continuing to chase generic Wayland window capture.

## Phase 2A: Generic Path

- [ ] Fix or validate the active Niri ScreenCast portal backend so window capture sources are actually exposed.
- [ ] Build a minimal prototype that selects a window through the portal flow.
- [ ] Capture frames from the selected PipeWire stream.
- [ ] Verify whether OBS built-in `Screen Capture (PipeWire)` already satisfies the workflow once the portal backend is working.
- [ ] Prove an OBS integration path for captured frames if built-in OBS behavior is still insufficient.
- [ ] Document the user workflow and limitations.

## Phase 2B: Plugin Path

- [x] Scaffold an OBS plugin from the plugin template.
- [x] Add a custom source type, tentatively `SnekStudio Source`.
- [x] Define source properties for selecting or binding the target.
- [x] Implement source lifecycle handling: create, update, render, destroy.
- [x] Connect the source to a cooperative shared-memory capture backend.

## Phase 2C: Cooperative Capture MVP

- [x] Define a stable shared-memory frame protocol for a SnekStudio-side publisher.
- [x] Add a standalone demo publisher that simulates the SnekStudio module.
- [x] Validate a repeatable local build for the OBS plugin and staged install layout.
- [x] Add source properties status diagnostics so stream state can be inspected without reading raw frame headers.
- [x] Draft an embeddable SnekStudio-side publisher reference implementation against the shared protocol.
- [x] Evaluate a pure GDScript SnekStudio mod path against the real SnekStudio codebase.
- [x] Prototype an in-tree `OBSFramePublisher` SnekStudio mod in the local cloned repo.
- [x] Replace the demo publisher with a real SnekStudio-side module.
- [x] Add reconnect and invalidation behavior polish inside the OBS plugin.
- [x] Add a fixed-resolution publishing mode for the SnekStudio module.

## Phase 3: Packaging

- [x] Ensure binaries install to `/usr/lib/obs-plugins`.
- [x] Ensure plugin data installs to `/usr/share/obs/obs-plugins/<plugin-name>`.
- [x] Add a packaging recipe suitable for the user's Arch setup.
- [x] Add draft packaging definitions for Debian and NixOS.
- [x] Add a GitHub Actions workflow that builds and publishes release artifacts.
- [x] Prepare actual AUR repository contents for `obs-snekstudio-source-git`.

## Phase 4: Validation

- [x] Test add-source flow in OBS on Wayland.
- [x] Test end-to-end frame publication from the SnekStudio `OBSFramePublisher` mod into the OBS plugin.
- [ ] Test capture stability during resize, hide, and close events.
- [ ] Test failure behavior when the target becomes invalid.
- [ ] Document known compositor or portal limitations.

## Upstream Preparation

- [x] Draft an upstream-ready PR shape for the SnekStudio OBS publisher work.
- [x] Prepare an external mod packaging path so SnekStudio-side work can stay out of the cloned upstream tree.
- [x] Prepare a self-contained Godot Asset Library package for the SnekStudio OBSFramePublisher mod.

## Decision Rule

- Prefer the generic solution if it becomes demonstrably workable within a short spike.
- If not, move to the plugin path only after confirming the blocker is not just the Wayland portal stack itself.
- For SnekStudio specifically, prefer cooperative capture over compositor-mediated window capture.
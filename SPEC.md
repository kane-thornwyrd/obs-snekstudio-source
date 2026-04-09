# OBS PipeWire Window Capture Specification

## Summary

This project exists to make it possible to capture a specific application window in OBS Studio while OBS is running on Wayland.

The preferred outcome is a generic Wayland-compatible solution that can be built quickly. If a generic path is not practical within a short timebox, the fallback is to build an OBS plugin that exposes a dedicated source, tentatively named `SnekStudio Source`, and solve the capture problem through that narrower integration.

## Problem Statement

Per-window capture on Wayland is harder than on X11 because capture access is mediated by compositor and portal security boundaries. A solution that works well in OBS must respect those constraints while still giving the user a reliable way to capture a single target window.

## Primary Goal

Allow a user to add a source in OBS that captures one specific application window on Wayland.

## Preference Order

1. Deliver a generic Wayland solution if it can reach a working MVP quickly.
2. If the generic path stalls, switch to an OBS plugin with a dedicated custom source.
3. For SnekStudio specifically, prefer a cooperative source pair over compositor-mediated window capture once the generic path is shown to be environmentally blocked.

## Candidate Paths

### Path A: Generic Wayland Capture

Use standard Wayland-friendly capture mechanisms, most likely PipeWire plus `xdg-desktop-portal`, to obtain a stream for a selected window.

Why this path is attractive:

- Broader usefulness beyond a single application.
- Better chance of working with stock OBS behavior or a thinner integration layer.
- Lower long-term coupling to one target application.

Known constraints:

- Window selection may require a portal picker rather than programmatic selection by title or class.
- Behavior may vary across compositors.
- The generic path may still need an OBS-side integration layer to present frames as a source cleanly.

Working assumption for MVP:

- A user-confirmed window picker is acceptable if it yields a usable single-window capture workflow.

### Path B: OBS Plugin With Custom Source

Build an OBS plugin that provides a dedicated source type, tentatively named `SnekStudio Source`, if that produces a working result faster than a generic solution.

Why this path is attractive:

- Better control over the OBS-side user experience.
- Easier to scope around one concrete workflow.
- More likely to produce a demonstrable MVP quickly if generic capture details become messy.

Known constraints:

- Narrower scope than a generic solution.
- More packaging and maintenance work.
- May still depend on PipeWire, portals, or other Wayland-compatible capture primitives underneath.

### Path C: Cooperative SnekStudio Source Pair

Build a matched pair:

- A SnekStudio-side publisher that exports frames intentionally.
- An OBS plugin that consumes those frames as a dedicated source.

Why this path is attractive:

- Avoids the compositor and portal failure modes that block arbitrary window capture on Wayland.
- Produces a stable, application-specific source identity inside OBS.
- Gives us room for reconnect handling, richer metadata, and source-specific UX.

MVP transport choice:

- A shared-memory frame buffer with a small fixed header.
- A single BGRA8 pixel format for the first milestone.
- A standalone demo publisher first, then a real SnekStudio-side module.

## MVP Requirements

- Run on Linux with Wayland.
- Work with the user's OBS package: `obs-studio-tytan652`.
- Let the user bind the source either to one target window or, for the cooperative path, to one SnekStudio frame stream.
- Display live frames in OBS with usable latency and stability for normal scene use.
- Handle window invalidation predictably when the target window closes, disappears, or becomes inaccessible.
- Be installable in the standard OBS layout used by this system.

## Install/Layout Assumption

For packaging against the user's OBS build:

- Plugin binaries go under `/usr/lib/obs-plugins`.
- Plugin assets go under `/usr/share/obs/obs-plugins/<plugin-name>`.

## Non-Goals

- Solving every compositor-specific window capture edge case in the initial version.
- Supporting X11 as the primary target.
- Building a fully general remote-control window capture system in the first milestone.
- Cross-platform support for the initial deliverable.

## Technical Inputs

Relevant external references already identified for this project:

- `pipewire-capture` for a quick PipeWire plus portal window-selection prototype.
- OBS Studio API documentation.
- OBS plugin template.
- `obs-studio-tytan652` AUR package and PKGBUILD for packaging and install layout.
- SnekStudio repository and documentation as the fallback integration reference.

## Decision Gate

The generic path should be attempted first, but only under a short timebox.

Switch to the plugin path if the generic spike cannot quickly demonstrate all of the following:

- A way to select a single target window.
- A stable live frame stream.
- A plausible integration path into OBS without compositor-specific hacks.

Switch specifically to the cooperative pair if:

- The target is SnekStudio rather than arbitrary windows.
- The Wayland portal path is blocked by compositor or backend behavior outside our control.
- We can get clean frame ownership inside SnekStudio.

For planning purposes, "quickly" means one to two focused implementation sessions, not an open-ended research effort.

## Suggested Architecture Direction

Prefer a small, layered design:

- Domain layer: capture target, source state, failure states, configuration model.
- Application layer: lifecycle orchestration, decision between generic and plugin paths, error handling.
- Adapter layer: OBS APIs, PipeWire or portal integration, packaging hooks.

Keep domain logic as pure as practical and isolate Wayland, PipeWire, and OBS side effects behind adapters.

## Initial Definition of Done

The first milestone is complete when:

- The repository contains a working prototype or plugin skeleton.
- There is a repeatable local build path.
- A user can add or launch the capture flow and get either one chosen window or one cooperative SnekStudio frame stream visible inside OBS on Wayland.
- Known limitations are documented.
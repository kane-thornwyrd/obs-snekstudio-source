#!/usr/bin/env python3

from __future__ import annotations

import argparse
import importlib.util
import os
import re
import subprocess
import sys
from dataclasses import dataclass


UINT32_RE = re.compile(r"<uint32\s+(\d+)>")


@dataclass(frozen=True)
class PortalProperty:
    name: str
    value: int | None
    raw: str


def run_command(command: list[str]) -> tuple[int, str, str]:
    process = subprocess.run(command, capture_output=True, text=True)
    return process.returncode, process.stdout.strip(), process.stderr.strip()


def get_env_value(name: str) -> str:
    return os.environ.get(name, "")


def get_portal_property(name: str) -> PortalProperty:
    command = [
        "gdbus",
        "call",
        "--session",
        "--dest",
        "org.freedesktop.portal.Desktop",
        "--object-path",
        "/org/freedesktop/portal/desktop",
        "--method",
        "org.freedesktop.DBus.Properties.Get",
        "org.freedesktop.portal.ScreenCast",
        name,
    ]
    code, stdout, stderr = run_command(command)
    raw = stdout or stderr
    if code != 0:
        return PortalProperty(name=name, value=None, raw=raw)

    match = UINT32_RE.search(stdout)
    value = int(match.group(1)) if match else None
    return PortalProperty(name=name, value=value, raw=stdout)


def pipewire_capture_available() -> tuple[bool, str]:
    if importlib.util.find_spec("pipewire_capture") is None:
        return False, "not installed"

    try:
        from pipewire_capture import is_available
    except Exception as exc:  # pragma: no cover - spike diagnostics
        return False, f"import failed: {exc}"

    try:
        return bool(is_available()), "ok"
    except Exception as exc:  # pragma: no cover - spike diagnostics
        return False, f"runtime check failed: {exc}"


def run_interactive_window_selection() -> int:
    try:
        from pipewire_capture import CaptureStream, PortalCapture
    except Exception as exc:
        print(f"pipewire_capture import failed: {exc}", file=sys.stderr)
        return 2

    portal = PortalCapture()
    session = portal.select_window()
    if not session:
        print("No session returned. Selection was likely cancelled or blocked.")
        return 1

    print("Portal session created:")
    print(f"  fd={session.fd}")
    print(f"  node_id={session.node_id}")
    print(f"  width={session.width}")
    print(f"  height={session.height}")

    stream = CaptureStream(session.fd, session.node_id, session.width, session.height)
    stream.start()
    frame = stream.get_frame()
    if frame is None:
        print("No frame received yet.")
    else:
        print(f"Received frame with shape={frame.shape}")
    stream.stop()
    session.close()
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Probe local Wayland portal capture readiness.")
    parser.add_argument(
        "--select-window",
        action="store_true",
        help="Open the interactive portal window picker using pipewire-capture.",
    )
    args = parser.parse_args()

    print("Session")
    print(f"  XDG_SESSION_TYPE={get_env_value('XDG_SESSION_TYPE')}")
    print(f"  XDG_CURRENT_DESKTOP={get_env_value('XDG_CURRENT_DESKTOP')}")
    print(f"  WAYLAND_DISPLAY={get_env_value('WAYLAND_DISPLAY')}")

    print("\nScreenCast Portal")
    for property_name in ("version", "AvailableSourceTypes", "AvailableCursorModes"):
        prop = get_portal_property(property_name)
        if prop.value is None:
            print(f"  {property_name}: unavailable ({prop.raw})")
        else:
            print(f"  {property_name}: {prop.value}")

    available, detail = pipewire_capture_available()
    print("\npipewire-capture")
    print(f"  installed_or_usable={available}")
    print(f"  detail={detail}")

    if args.select_window:
        print("\nInteractive Capture Test")
        return run_interactive_window_selection()

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

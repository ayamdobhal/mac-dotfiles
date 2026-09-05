# 0002: Implement the operations suite over authoritative session adapters

**Status:** accepted and implemented

## Decision

Complete the approved operations-suite components as fixed Quickshell overlays
without changing niri's ownership of windows or columns. Quick View owns local
chrono, calendar, bounded telemetry, and MPRIS presentation. Quick Toggles and
Maintenance Bay expose writable native NetworkManager, BlueZ, and PipeWire
properties plus packaged brightness and session-inhibitor gaps. All actions
retain explicit lifecycle state.

Incident Echelon reads bounded JSON from the existing mako owner rather than
claiming `org.freedesktop.Notifications` before parity. This provides live and
historical evidence, dismissal, filters, and DND while preserving the working
fallback. The Column Insertion Gate consumes Quickshell desktop entries and
declarative targets, and launches argument arrays through `app2unit`.

## Consequences

- No fixture data remains in production surfaces.
- Weather is visibly unavailable rather than synthesized.
- Current-stack insertion remains disabled because a newly launched window
  cannot yet be identified safely for a follow-up niri action.
- Mako and fuzzel remain installed and operational until their documented
  parity gates pass.
- `brightnessctl`, `lm_sensors`, BlueZ utilities, and media tools were already
  declaratively installed, so this checkpoint requires no new package.
- Personal `wallpaper.png` remains ignored local data and is not a flake input.

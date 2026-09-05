# 0003: Adopt smoked amber material and semantic chassis cuts

**Status:** accepted and implemented

## Context

The refreshed OpenDesign contract replaces cold opaque rectangles with a warm
smoked-polycarbonate material system and constrains all diagonal geometry to
8px, 14px, and 26px 45-degree cuts. These changes refine shell-owned surfaces;
they do not alter niri's ownership of managed windows or column movement.

## Decision

- Generate spine, primary, secondary, evidence, dense, notice, and solid warm
  material tokens from Nix, including an opacity multiplier.
- Keep reduced transparency independent from reduced motion. A Quick Toggles
  control changes the current session, while the Home Manager option supplies
  its persistent default.
- Use one reusable `Components/Chassis.qml` primitive for the approved stepped,
  dogleg, notched, station, MAGI, and insertion profiles.
- Keep tables, inputs, sliders, calendar cells, and dense evidence rows
  rectangular. Directional cuts are not decorative.
- Render the personal wallpaper at full strength beneath a light warm mask.
- Use the opaque warm-umber fallback where compositor backdrop blur is not
  available; do not simulate blur by softening text or nested content.
- Apply the same warm base to Alacritty, fuzzel, and mako without changing their
  fallback ownership.

## Consequences

Quick View becomes a wider Chrono/Environment sidecar, Maintenance reads as a
fixed service dogleg, Incident history attaches to the monitor edge, and the
launcher points toward insertion without drawing a fake window. The shell
continues to expose real service data and retains all existing fallback and
layering boundaries.

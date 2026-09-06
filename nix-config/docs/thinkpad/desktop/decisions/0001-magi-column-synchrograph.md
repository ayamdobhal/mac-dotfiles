# ADR 0001: adopt the MAGI Column Synchrograph

- Status: accepted
- Date: 2026-09-02

## Context

The earlier desktop contract used a conventional top status rail and described
the niri workspace as if the shell needed to visualize managed application
windows. The approved OpenDesign work established a more faithful physical
model: niri already owns a horizontally scrolling field of columns and a
vertical workspace sequence, while Quickshell should supply fixed monitor
instrumentation and transient overlays.

The accepted references are the local `nerv-command-surface` brand and
component specifications, the two review prototypes, and the selected
background direction. They are read-only design artifacts, not runtime source.

## Decision

Adopt the MAGI Column Synchrograph as the production direction.

- Replace the top status rail with a 96px full-height left transit spine.
- Model workspaces as vertical floors, columns as a horizontal procession, and
  stack members as a vertical sequence inside one column.
- Let the spine reserve the only shell exclusive zone.
- Put background registration beneath managed windows and give it an empty
  input region.
- Put Quick View, Quick Toggles, Maintenance Bay, Incident Echelon, and the
  Column Insertion Gate on fixed overlay-layer surfaces with no exclusive zone.
- Keep incidents physically anchored at the upper-right monitor edge and
  independent of the mutually exclusive primary overlay group.
- Use real niri/service state or explicit unavailable/fixture labeling. Never
  present review data as live.
- Keep mako and fuzzel until their Quickshell replacements pass parity.

## Prototype mapping

The transit spine, background wallpaper, registration treatment, service
sidecars, maintenance ledger, incident history, and launcher become real shell
UI. The prototype's moving application planes, fake app contents, offscreen
counts, synthetic device/weather/media state, Surface Test rail, and annotation
captions were review-only visualizations. Production must not render them.

The user-supplied `home/quickshell/assets/wallpaper.png` is a personal local
override and is excluded from Git and the flake source. Quickshell watches the
file for replacements and renders it across the complete click-through
background with a controlled dark mask and per-monitor aspect crop. When the
override is absent, the reproducible shell remains functional with its void
background and registration treatment.

## Consequences

The shell remains legible as niri moves the real field, and transient tools
cannot be mistaken for managed columns. The first checkpoint can ship honest
read-only evidence while leaving runtime mutations, notification ownership,
and launcher parity to later checkpoints. Multi-monitor composition requires
one spine/background per monitor and opens interactive overlays only on the
focused niri output.

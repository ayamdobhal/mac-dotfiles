# NERV command surface

## Approved direction

The desktop is the **MAGI Column Synchrograph**: a severe analog-computer and
bio-diagnostics command surface built around niri's real spatial model. Black
void dominates, red establishes the fixed synchronization datum, amber labels
evidence, bone carries readable data, green confirms health, and violet or
cobalt appears only as a narrow identity, history, or recovery trace.

The shell is not a conventional dashboard and does not simulate a window
manager. Niri renders and moves application windows. Quickshell contributes
fixed monitor instrumentation, real compositor evidence, background
registration, and transient control surfaces.

## Spatial grammar

1. A 96px full-height MAGI transit spine is fixed to each physical monitor's
   left edge. It is the only persistent shell surface allowed to reserve an
   exclusive zone.
2. Workspaces are a vertical sequence of floors. Moving between them is a
   vertical transfer that replaces the active horizontal field.
3. Windows in a workspace are a potentially unbounded horizontal procession of
   columns. Focus left and right moves between columns.
4. A column may contain a vertical stack. Focus up and down moves only within
   that stack. Workspace, column, and stack must never be visualized as a tiled
   pager grid.
5. The fixed sync gate and registration marks sit behind real windows or in
   narrow noninteractive edge regions. They provide a physical datum without
   obscuring managed content.
6. Quick View, Quick Toggles, Maintenance Bay, Incident Echelon, and the Column
   Insertion Gate are compositor overlays with no exclusive zone. Their
   stepped, notched, or directional chassis are fixed shell silhouettes and
   must not resemble additional managed columns.
7. Incident popups and history remain anchored to the physical upper-right
   monitor edge. They never travel with niri's horizontal field.

## Principles

- **Operational, not ornamental.** Every persistent mark describes structure,
  state, time, focus, or an available action.
- **Niri is authoritative.** Do not draw fake application windows, fake column
  motion, or invented compositor state.
- **State is explicit.** Interfaces expose `unknown`, `unavailable`, `busy`,
  `ready`, `warning`, and `error`. A boolean value never substitutes for
  lifecycle state.
- **Evidence precedes control.** Mutating controls remain inert until their
  service adapter can confirm the authoritative result.
- **Asymmetric but registered.** Strong baselines, thick red structural masses,
  thin amber measurement rules, and deliberate void replace floating cards.
- **References are not an asset library.** Avoid fake Japanese text,
  proprietary interface marks, and counterfeit typography. Wallpaper imagery
  must be user-supplied or appropriately licensed.

## Foundation tokens

Tokens are authored once in `home/quickshell.nix` and generated into QML. A
component may consume a semantic token but must not copy private color,
spacing, typography, state, or motion constants.

### Color

| Token | Approved source | Role |
| --- | --- | --- |
| `void` | `oklch(0.12 0.018 48)` | Primary field; roughly 70% of a frame |
| `surface` | `oklch(0.22 0.052 52 / 0.58)` | Controlled smoked-amber evidence planes |
| `offwhite` | `oklch(0.935 0.018 83)` | Primary data and numerals |
| `muted` | `oklch(0.76 0.038 67)` | Secondary evidence |
| `border` | `oklch(0.52 0.09 55 / 0.78)` | Warm measurement dividers |
| `signal-red` | `oklch(0.585 0.238 28)` | Spine, gate, active structure |
| `signal-red-deep` | `oklch(0.43 0.19 28)` | Dense and pressed red planes |
| `signal-orange` | `oklch(0.782 0.168 64)` | Measurement and attention labels |
| `hazard-yellow` | `oklch(0.905 0.183 105)` | Keyboard focus and finite recovery |
| `acid-green` | `oklch(0.8393 0.2119 126)` | Healthy or confirmed state only |
| `recovery-cobalt` | `oklch(0.584 0.145 268)` | Narrow recovery history |
| `identity-purple` | `oklch(0.515 0.195 304)` | Narrow identity trace |

Approximate visual allocation is 70% black/near-black, 14% red, 8% amber or
yellow, 6% off-white, and no more than 1% each green and violet/cobalt. State
must be encoded by text and structure as well as color.

### Typography

- Display numerals and headings: IBM Plex Sans Condensed.
- Body and control copy: IBM Plex Sans.
- Telemetry and evidence: Commit Mono, with JetBrains Mono as a fallback.
- Identity stamp only: Orbitron.

Enormous condensed numerals may sit beside 8-11px monospaced evidence. Body and
control labels remain 13-15px. Orbitron is not a general interface face.

### Geometry

- Base spacing unit: 4px; common steps: 8, 12, 16, 24, and 32px.
- Targets are at least 36px; primary actions are at least 44px.
- The only diagonal tokens are 8px detail, 14px evidence, and 26px structural
  cuts. Every cut is 45 degrees and must encode attachment, direction,
  hierarchy, severity, or consequence.
- Major shell chassis use one intentional silhouette: Quick View has a stepped
  lower-right edge, Quick Toggles and Maintenance use a right dogleg, Incident
  history has a notched monitor-edge attachment, and the launcher tapers into
  a right-facing insertion spear.
- Calendar cells, tables, sliders, inputs, and dense control interiors remain
  rectilinear for measurement and usability.
- Red masses establish structure. Amber one-pixel rules measure. Neutral rules
  separate evidence.
- No rounded cards, generic glassmorphism, decorative outlines, pill islands,
  or generic dashboard grids. Backdrop blur is allowed only once per top-level
  smoked material plane, never on nested rows.

### Smoked amber material

The wallpaper remains continuous beneath warm translucent shell planes. The
spine targets 76% warm umber, primary sheets 67%, secondary insets 50%,
evidence rails 70%, dense service planes 82%, and monitor-edge notices 86%.
The generated `materialOpacity` multiplier adjusts these semantic alpha values
without changing their roles.

Reduced transparency is independent of reduced motion. It replaces every
translucent plane with opaque warm umber while retaining identical geometry,
focus, and animation behavior. The live `MATERIAL / TRANS` control changes the
session mode; `nervDesktop.reducedTransparency` supplies the persistent Nix
default. Since niri currently provides no compositor backdrop-blur protocol,
production uses the approved warm tint without claiming blur and retains the
documented opaque fallback. Blur radius tokens are generated for a future
supported top-level implementation.

### Motion

Motion is finite and communicates a state change:

- Micro acknowledgment: 120-160ms.
- Panel deployment: 280ms; close: 160ms.
- Horizontal column evidence response: at most 420ms, then still.
- Vertical stack evidence response: at most 220ms, then still.
- Workspace transfer acknowledgment: at most 340ms, then still.

The generated `reducedMotion` token is the complete equivalent of
`prefers-reduced-motion`. When enabled, all duration tokens resolve to zero;
travel, scan, parallax, trace, and waveform motion disappears. State still
changes immediately with static color, text, and outline feedback. Continuous
scanlines, glows, waveforms, and decorative loops are forbidden in both modes.

## Production surfaces

### Background and registration

The user-supplied wallpaper fills the complete background with an intentional
per-monitor cover crop. Only a light warm mask limits contrast so its quiet
left/center field remains available for evidence and its purple/orange armor
stays concentrated on the far right. Real niri windows naturally mask it. The
sync gate and registration crosses live on this click-through background
layer. The older `armored-background-option2.png` reference is historical and
is not a production dependency.

### MAGI transit spine

The 96px fixed spine contains:

- system identity and adapter lifecycle;
- vertical workspace stations and the active floor;
- focused application title;
- real column and stack indices/counts when niri exposes them;
- NetworkManager, CPU, memory, UPower, clock, and date evidence;
- redundant loading, unavailable, ready, warning, and error treatment.

Workspace stations may perform a real niri workspace focus action. Other
segments open transient surfaces rather than expanding the exclusive zone.

### Quick View

A stepped fixed sidecar with a distinct 50% Chrono inset beside environment,
bounded CPU/memory/thermal histories, and MPRIS state. Weather remains an
explicit unavailable channel until a provider is configured; it never blocks
the calendar, telemetry, or media and never presents sample data as live.

### Quick Toggles

A 390-420px command slab exposing normalized NetworkManager, BlueZ, PipeWire,
brightness and session-inhibitor state. Radio, privacy, volume and brightness
actions use writable native APIs or packaged commands and remain busy until
the service adapter confirms the resulting state.

### Maintenance Bay

A larger fixed category ledger for NetworkManager access points, BlueZ devices,
Ethernet link evidence, PipeWire routes/privacy, UPower/brightness, MPRIS,
niri, and immutable NixOS ownership evidence. Persistent policy always routes
to `/home/ayam/nix`.

### Incident Echelon

Toasts stay at the physical upper-right edge. The independent history surface
reads bounded live and historical incident data from `makoctl`, supports
dismissal and DND routing, and never claims the notification D-Bus name. Mako
remains the popup owner until native urgency, actions, grouping, progress and
keyboard parity are validated.

### Column Insertion Gate

A fixed launcher overlay searches Quickshell's real desktop-entry model plus
declarative recent, settings and safe-command targets, then starts commands
through `app2unit`. It describes insertion into niri's field but does not
animate fake columns. Current-stack placement is unavailable until niri can
identify the newly launched window authoritatively. Fuzzel remains available
until launch failure and desktop-action parity are validated.

## Interaction and layering

- Quick View, Quick Toggles, Maintenance Bay, and launcher are mutually
  exclusive. Incident history remains independent.
- Primary overlays take keyboard focus on open, expose a visible hazard-yellow
  focus outline, follow a logical Tab order, and close with Escape.
- Overlay windows use the layer-shell overlay layer and `exclusiveZone = 0`.
- Only `shell.qml` creates top-level layer-shell windows.
- Background and registration windows have an empty input region.

## Prototype-to-production contract

| Prototype element | Production mapping |
| --- | --- |
| 96px transit spine | Real fixed Quickshell exclusive surface |
| Workspace floors | Real niri workspace data and focus action |
| Focus/column/stack labels | Real `niri msg --json` snapshots |
| Wallpaper, sync gate, registration | Click-through background layer |
| Quick View/Toggles/Maintenance/Incidents/Launcher | Fixed overlay-layer surfaces |
| Notification stack | Mako now; Quickshell only after parity |
| Moving column planes and application contents | **Review-only visualization; never rendered** |
| Offscreen column counts and animated travel | **Review-only until niri exposes authoritative data** |
| Surface Test rail and state selectors | **Prototype harness only** |
| Invented weather, devices, media, incidents, graphs | **Fixture evidence only; never labeled live** |
| Review annotations and spatial captions | **Design artifact only** |

## Quality gates

- Body text meets WCAG AA contrast; telemetry is not exempt.
- Every pointer action has a visible keyboard path.
- Test 1x and fractional scaling, narrow and ultrawide layouts, multiple
  monitors, offline boot, missing adapters, device hotplug, and no-player state.
- Verify finite motion, reduced motion, high transparency, and solid material
  independently; motion and transparency preferences must not affect each
  other.
- Confirm every production asset is repository-owned or reproducibly copied
  with its provenance recorded. Personal wallpaper overrides are ignored local
  data and must degrade cleanly to the void background when absent.

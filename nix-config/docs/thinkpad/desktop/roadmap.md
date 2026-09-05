# Delivery roadmap

## Phase 1: design

### D1 — Foundation

- Approve the visual thesis, palette, typography and motion language in
  `DESIGN.md`.
- Create an original or licensed EVA-01-inspired background direction.
- Define 1x, fractional-scale and reduced-motion variants.
- Produce a token sheet covering default, hover, focus, active, busy,
  unavailable, warning and critical states.

**Gate:** tokens meet contrast targets and the composition is recognizable in
grayscale without relying on purple/green alone.

### D2 — Core shell

- Design the 96px transit spine with realistic long app names, vertical
  workspace stations, and degraded connectivity states.
- Design Quick View in populated, offline and no-media states.
- Design Quick Toggles in all radio/privacy states.
- Validate fixed overlay ownership and keyboard travel from spine segments.

**Gate:** every pointer interaction has a visible keyboard path.

### D3 — Settings and notifications

- Design Wi-Fi authentication, Bluetooth discovery, Ethernet details, audio
  routing and immutable NixOS information.
- Design notification severities, grouping, actions, progress, history and DND.
- Define error copy and recovery actions for missing services.

**Gate:** no surface assumes a device, network, battery, media player or weather
provider is available.

### D4 — Background and application themes

- Design idle, media-playing, focused-window and multi-monitor background
  compositions.
- Produce terminal and VS Code theme specimens from the shared tokens.
- Test foreground application readability with transparency enabled.

**Gate:** review at common display crops and with reduced motion/transparency.

### Design workflow

Use OpenDesign plus the Frontend Design skill for each direction, then use the
Product Design plugin to compare exactly three variants before locking one.
Capture the accepted state and decision rationale in `docs/desktop/decisions/`.
Use Playwright/Screenshot tooling for rendered prototype evidence. HTML design
prototypes are design artifacts only; production remains Nix and Quickshell.

## Phase 2: implementation

### I1 — Production vertical slice

- Add `home/quickshell.nix` and deploy a minimal QML source tree.
- Generate Quickshell color, typography, spacing, state and motion tokens from
  Nix.
- Start Quickshell through `app2unit` with a health-checkable user unit.
- Render the per-monitor wallpaper, click-through registration, and
  fixed 96px transit spine.
- Add real niri, clock, CPU and memory state plus normalized native service
  adapters.
- Scaffold correctly layered Quick View, Quick Toggles, Maintenance Bay,
  Incident Echelon, and Column Insertion Gate surfaces.

**Checkpoint status:** implemented by the first production checkpoint; visual
hardening and parity work continue below.

### I2 — Read-only depth and authoritative actions

- Add temperatures, detailed network routes/devices, audio nodes, power detail,
  complete MPRIS selection, and bounded history traces.
- Add radio/audio/privacy actions only with authoritative confirmation and
  explicit recovery.

**Checkpoint status:** implemented for thermal history, NetworkManager/BlueZ
device evidence, PipeWire defaults, battery health, brightness, media and
bounded mako history. Route/DNS expansion remains hardening work.

### I3 — Main interactions

- Implement Quick View, Quick Toggles and their keyboard equivalents.
- Add runtime actions for radios, audio, microphone, DND, keep-awake and
  brightness with authoritative state confirmation.

**Checkpoint status:** implemented. Weather remains explicitly unavailable
until a provider and cache policy are selected.

### I4 — Maintenance Bay

- Implement NetworkManager, BlueZ and PipeWire details and actions.
- Show NixOS generation/build information as read-only data with a path back to
  the repository for persistent changes.

**Checkpoint status:** implemented with a six-category authority ledger.

### I5 — Notifications and launcher migration

- Implement notification server, history, actions, progress, grouping and DND.
- Pass parity tests, then remove mako.
- Implement launcher/search, pass parity tests, then remove fuzzel.

**Checkpoint status:** in progress. Incident history, DND and dismissal are
mako-backed; launcher search covers desktop entries, declarative targets and
safe commands through app2unit. Mako and fuzzel remain installed because
native notification actions/grouping/progress and launcher failure/desktop
action parity have not passed.

### I6 — Background and application themes

- Add licensed/original background assets, bounded parallax, media and time.
- Select a cross-application theme distributor and generate any remaining
  Alacritty and VS Code details from the semantic palette.
- Add transparency and reduced-motion/transparency controls.

**Checkpoint status:** in progress. The personal wallpaper, semantic smoked
materials, 8/14/26px chassis system, independent transparency control,
Alacritty theme, and mako/fuzzel transition themes are implemented. Native
top-level blur awaits compositor protocol support; VS Code distribution and
broader toolkit overrides remain pending.

### I7 — Hardening

- Test multiple monitors, fractional scaling, device hotplug, service restarts,
  suspend/resume, offline boot and no-player state.
- Measure idle CPU/memory and animation frame pacing.
- Run the complete flake validation and NixOS toplevel build.

## Definition of done

- Rebuilding the flake recreates the complete shell and design toolchain.
- No imperative installer or mutable package manager is required.
- No committed copyrighted Evangelion asset is required for a functional build.
- The shell remains usable with animation, transparency, weather and media
  artwork disabled.
- Stopgap applications are absent only after their replacements meet parity.

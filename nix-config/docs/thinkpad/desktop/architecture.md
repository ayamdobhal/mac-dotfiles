# Desktop architecture

## Ownership boundary

| Concern | Owner |
| --- | --- |
| Bluetooth, PipeWire, UPower, NetworkManager and graphics | NixOS modules |
| User packages, Codex tools and dotfiles | Home Manager |
| Shared palette, fonts, spacing, state and motion tokens | `home/quickshell.nix` |
| Shell UI, interaction and transient session state | Quickshell QML |
| Compositor layout, shortcuts and startup | `home/niri.nix` |
| Visual tokens and behavior contract | `DESIGN.md` |

Quickshell is a presentation and session-control layer. It may call stable
system APIs, D-Bus services, or small packaged CLIs; it must not become a second
configuration system.

## Planned source tree

```text
home/
  desktop.nix                 # packages, themes, Codex/OpenDesign
  niri.nix                    # compositor and shell startup
  quickshell.nix              # deploy QML and generate token data
  quickshell/
    shell.qml                 # single composition root
    Components/               # shared controls and primitives
    Services/                 # normalized state adapters
    Surfaces/
      Background.qml
      Spine.qml
      IncidentEchelon.qml
      Launcher.qml
      MaintenanceBay.qml
      QuickToggles.qml
      QuickView.qml
    Widgets/                  # calendar, graphs, media, telemetry
    js/                       # bounded pure helpers only
```

`shell.qml` owns the layer-shell surfaces and imports focused components.
Services expose typed, normalized state; surfaces do not parse command output
or implement transport logic themselves.

## Runtime data map

| Capability | Preferred source | Packaged fallback |
| --- | --- | --- |
| Workspaces/focused app | Quickshell Niri integration / IPC | `niri msg --json` |
| CPU and memory | Quickshell system APIs, `/proc` sampling | `lm_sensors` for temperatures |
| Wi-Fi and Ethernet | NetworkManager D-Bus | `nmcli` |
| Bluetooth | BlueZ D-Bus | `bluetoothctl` |
| Audio and microphone | Quickshell PipeWire integration | `wpctl` |
| Media | Quickshell MPRIS integration | `playerctl` |
| Battery/power | UPower D-Bus | `upower` |
| Brightness | sysfs where permitted | `brightnessctl` |
| Weather | cacheable HTTPS provider adapter | stale cache + offline state |
| Notifications | Quickshell notification server after parity | bounded `makoctl list/history -j` during migration |
| DND | Quickshell-owned session state | persisted user setting |
| Keep awake | systemd-inhibit D-Bus/process | `systemd-inhibit` |
| Audio visualization | Quickshell process adapter | `cava` raw output |

Existing Quickshell modules and nixpkgs packages take priority over custom
parsers or daemons. GUI code and visual components are always original to this
project even when their backend behavior uses existing packages.

The operations checkpoint uses the already-declared `brightnessctl`,
`lm_sensors`, and `mako` packages. NetworkManager, BlueZ, PipeWire, UPower,
MPRIS, and desktop entries use Quickshell's native models and writable
properties; packaged commands are limited to gaps in those models.

## Process model

```text
NixOS services -> D-Bus / IPC / procfs -> Quickshell Services
                                           |
                                           v
                                  normalized session state
                                           |
                    +----------------------+---------------------+
                    |                      |                     |
                   Spine                Overlays             Background
                    |                      |                     |
                    +--------- Maintenance / actions -----------+
```

Only the composition root creates top-level windows. This keeps layer ordering,
exclusive zones, multi-monitor instances and reload behavior predictable.

## State and interaction rules

- Services distinguish `unknown`, `unavailable`, `busy`, `ready` and `error`;
  false must not double as “not loaded.”
- User actions update optimistically only when rollback is clear. Connectivity
  and privacy controls wait for authoritative confirmation.
- Spine segments are clickable and keyboard-addressable; panels are never
  hover-only.
- Maintenance Bay is mutually exclusive with Quick View, Quick Toggles, and the
  launcher; Incident Echelon is independent.
- Multi-monitor global state has one owner. Each monitor renders its own spine
  and background; overlays open only on the focused niri output.

## Theme pipeline

The checked-in NERV semantic palette is the source of truth. Nix generates
Quickshell color, typography, spacing, state, motion, 8/14/26px cut, smoked
material, opacity, and reduced-transparency tokens. QML may change only the
current session's transparency mode; the next activation restores the
declarative default.

The pipeline produces immutable theme configuration for:

1. Quickshell semantic and material tokens.
2. Alacritty's warm transparent terminal surface; VS Code remains pending.
3. Warm notification and launcher-fallback styling during the mako/fuzzel
   transition.
4. GTK/Qt overrides where the target supports them safely.

Any future cross-application theme distributor must not flatten state colors
into a generic base16 accent: purple keeps identity semantics, while green,
amber, and red keep health, warning, and critical meanings. `matugen` is
available for later user-selected wallpaper derivation, but the NERV palette
remains the checked-in default and semantic state colors are never generated
from a wallpaper.

Niri currently exposes no supported compositor backdrop-blur protocol. The
shell therefore uses warm alpha planes and the approved opaque-umber reduced
transparency fallback. Generated blur-radius tokens document the future
top-level behavior; nested QML controls never apply blur effects.

## Startup and replacement strategy

Quickshell is launched from `home/niri.nix` through `app2unit`, matching the
repository startup policy. During development it starts alongside mako and does
not claim the notification D-Bus name. Once notification parity passes, the
mako startup entry and package are removed in the same checkpoint. Fuzzel is
handled similarly after the launcher is implemented.

## Validation layers

1. QML formatting/static checks and a Quickshell test launch.
2. Component screenshots at 1x and fractional scale.
3. Interaction tests for keyboard access, mutual exclusion, and unavailable states.
4. Full-session smoke test under Niri.
5. Repository validation with `nix flake check path:.` and the NixOS toplevel
   build specified in `AGENTS.md`.

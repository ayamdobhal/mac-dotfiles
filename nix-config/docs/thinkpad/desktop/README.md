# NERV desktop project

`DESIGN.md` is the approved MAGI Column Synchrograph contract; this directory
records architecture, decisions, scope, and acceptance gates. Production is a
Nix-deployed Quickshell shell for niri, not an HTML prototype.

## Documents

- [`../../DESIGN.md`](../../DESIGN.md): visual thesis, tokens, surfaces and
  accessibility constraints.
- [`architecture.md`](architecture.md): Nix/Quickshell boundaries, data sources
  and component shape.
- [`roadmap.md`](roadmap.md): checkpoints for design and implementation.
- [`decisions/`](decisions/): accepted design and architecture records.

## Toolchain

The flake installs the complete design toolchain declaratively:

- OpenDesign 0.21.1 daemon and local web UI at `http://127.0.0.1:5174`.
- OpenDesign MCP bridge registered in Codex.
- Frontend Design, Playwright and Screenshot skills.
- OpenAI Product Design plugin through a Nix-managed personal marketplace.
- Quickshell and the runtime helpers required for telemetry, media, networking,
  audio, display brightness and theming.

No `npm install`, `codex plugin add`, `od mcp install`, or manual copy into the
home directory is part of the setup.

## Implementation stack

- NixOS and Home Manager own services, packages and generated configuration.
- Nix generates the approved semantic palette, typography, spacing, state, and
  motion tokens consumed by Quickshell.
- Quickshell supplies the original shell GUI and interaction layer in QML.
- Niri supplies composition, input, layout and graphical-session startup.
- Matugen remains an optional future wallpaper-derived input, subordinate to
  the checked-in NERV semantic colors.

Theme distribution is infrastructure, not a GUI kit. Quickshell surfaces remain
designed specifically for this project rather than reusing third-party shell
widgets.

## Source policy

The operating system, services, packages, dotfiles and generated configuration
are Nix-owned. Quickshell itself is authored in QML (`.qml`) with small
JavaScript (`.js`) helpers only where declarative QML is insufficient.
Quickshell does not use C# `.cs` files; if “cs files” meant “Quickshell source,”
QML is the supported equivalent. Compiled helper daemons are out of scope until
profiling proves they are necessary.

Mako and fuzzel remain as explicit stopgaps during design and early shell
development. They are removed only when Quickshell notification and launcher
parity is verified.

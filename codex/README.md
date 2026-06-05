# Codex Config

Home Manager syncs durable Codex files from this directory into `~/.codex`.

`config.toml.example` is intentionally not linked. The live
`~/.codex/config.toml` currently contains a private MCP HTTP header, so it stays
local until that value can be moved into a secret manager or an environment
indirection that Codex supports for headers.

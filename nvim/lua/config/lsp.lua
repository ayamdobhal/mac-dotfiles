local capabilities = require("blink.cmp").get_lsp_capabilities()

-- Rust
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml" },
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      checkOnSave = { command = "clippy" },
      cargo = { allFeatures = true },
      procMacro = { enable = true },
      diagnostics = { disabled = { "unresolved-proc-macro" } },
    },
  },
})

-- Elixir
vim.lsp.config("elixirls", {
  cmd = { "elixir-ls" },
  filetypes = { "elixir", "eelixir", "heex", "surface" },
  root_markers = { "mix.exs" },
  capabilities = capabilities,
  settings = {
    elixirLS = {
      dialyzerEnabled = false,
      fetchDeps = false,
    },
  },
})

-- TypeScript / JavaScript / React
-- root_markers: tsconfig first so vtsls roots at the actual TS project,
-- not the monorepo root where .git/Cargo.toml live
vim.lsp.config("vtsls", {
  cmd = { "vtsls", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json" },
  capabilities = capabilities,
  settings = {
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      preferences = { importModuleSpecifier = "non-relative" },
      tsserver = {
        maxTsServerMemory = 8192,
      },
    },
    vtsls = {
      enableMoveToFileCodeAction = true,
      autoUseWorkspaceTsdk = true,
    },
  },
})

-- Python
vim.lsp.config("basedpyright", {
  cmd = { "basedpyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "setup.py", "pyrightconfig.json" },
  capabilities = capabilities,
  settings = {
    basedpyright = {
      analysis = {
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = true,
      },
    },
  },
})

vim.lsp.enable({ "rust_analyzer", "elixirls", "vtsls", "basedpyright" })

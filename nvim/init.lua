-- Leader keys (must be set before lazy.nvim loads)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core settings
require("config.options")
require("config.diagnostics")

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load all plugin specs from lua/plugins/
-- Home Manager may link the config into the read-only Nix store. Keep a
-- writable lockfile in state in that case, seeded from the repository pin.
local lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json"
if vim.fn.filewritable(lockfile) ~= 1 then
  local state = vim.fn.stdpath("state")
  vim.fn.mkdir(state, "p")
  local writable_lockfile = state .. "/lazy-lock.json"
  if not vim.uv.fs_stat(writable_lockfile) then
    assert(vim.uv.fs_copyfile(lockfile, writable_lockfile))
  end
  -- fs_copyfile preserves the store file's read-only mode.
  assert(vim.uv.fs_chmod(writable_lockfile, 384)) -- 0600
  lockfile = writable_lockfile
end
require("lazy").setup({ import = "plugins" }, { lockfile = lockfile })

-- LSP servers (after plugins so blink.cmp is available)
require("config.lsp")

-- Buffer path utilities
require("config.buffer-path").setup()

-- Keymaps (after everything else is loaded)
require("config.keymaps")

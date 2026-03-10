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
require("lazy").setup({ import = "plugins" })

-- LSP servers (after plugins so blink.cmp is available)
require("config.lsp")

-- Keymaps (after everything else is loaded)
require("config.keymaps")

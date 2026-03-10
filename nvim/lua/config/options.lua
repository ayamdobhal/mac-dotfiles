local o = vim.opt

o.termguicolors = true
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.wrap = false
o.scrolloff = 8
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.cursorline = true
o.splitright = true
o.splitbelow = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.ignorecase = true
o.smartcase = true
o.inccommand = "split"
o.autoread = true

-- Reload files changed outside Neovim
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  command = "checktime",
})

-- Flash yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function() vim.hl.on_yank({ timeout = 200 }) end,
})

-- Persistent undo (survives closing/reopening files)
local undodir = vim.fn.stdpath("state") .. "/undo"
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end
o.undofile = true
o.undodir = undodir

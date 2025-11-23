-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic editor settings
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

-- Load plugins
require("plugins")

-- Keymaps helper
local map = vim.keymap.set

---------------------------------------------------------------------
-- Telescope / Navigation (VSCode-style + Ctrl fallbacks)
---------------------------------------------------------------------

-- File picker (like VSCode Cmd+P)
map("n", "<C-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
map("n", "<D-p>", "<cmd>Telescope find_files<cr>", { desc = "Find files (Cmd+P)" })

-- Search in current file (VSCode-style Cmd+F)
map("n", "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Search in file" })
map("n", "<D-f>", "<cmd>Telescope current_buffer_fuzzy_find<cr>", { desc = "Search in file (Cmd+F)" })

-- Project-wide search (like Cmd+Shift+F)
map("n", "<leader>sf", "<cmd>Telescope live_grep<cr>", { desc = "Search in project" })
map("n", "<D-S-f>", "<cmd>Telescope live_grep<cr>", { desc = "Search in project (Cmd+Shift+F)" })

-- File tree toggle (like Cmd+B equivalent)
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "File explorer" })

---------------------------------------------------------------------
-- LSP Keybinds
---------------------------------------------------------------------

map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "References" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>f", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "Format" })

---------------------------------------------------------------------
-- Buffer management
---------------------------------------------------------------------

map("n", "<leader>q", "<cmd>bd<cr>", { desc = "Close buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

---------------------------------------------------------------------
-- Telescope extras
---------------------------------------------------------------------

map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { desc = "Help" })

---------------------------------------------------------------------
-- Comment toggle
---------------------------------------------------------------------

map("n", "<leader>/", function()
  require("Comment.api").toggle.linewise.current()
end, { desc = "Toggle comment" })

map("v", "<leader>/", function()
  local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
  vim.api.nvim_feedkeys(esc, "nx", false)
  require("Comment.api").toggle.linewise(vim.fn.visualmode())
end, { desc = "Toggle comment" })

---------------------------------------------------------------------
-- Diagnostics appearance (inline warnings/errors)
---------------------------------------------------------------------

vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    spacing = 2,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Next / previous diagnostic
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })

-- Show diagnostics for current line in a floating window
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })

---------------------------------------------------------------------
-- Split management (ultrawide QoL)
---------------------------------------------------------------------

map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Horizontal split" })
map("n", "<leader>se", "<cmd>wincmd =<cr>", { desc = "Equalize splits" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close split" })

-- Movement between splits (built-in, just documenting):
-- Ctrl+h / Ctrl+j / Ctrl+k / Ctrl+l

---------------------------------------------------------------------
-- Persistent undo (remember undo history even after closing files)
---------------------------------------------------------------------

local undodir = vim.fn.stdpath("state") .. "/undo"
if vim.fn.isdirectory(undodir) == 0 then
  vim.fn.mkdir(undodir, "p")
end

vim.opt.undofile = true
vim.opt.undodir = undodir

---------------------------------------------------------------------
-- Cheatsheet popup: <leader>? (Space + ?)
---------------------------------------------------------------------

local function open_cheatsheet()
  local filepath = vim.fn.stdpath("config") .. "/KEYBINDS.md"

  -- read file content
  local lines = {}
  local f = io.open(filepath, "r")
  if f then
    for line in f:lines() do
      table.insert(lines, line)
    end
    f:close()
  else
    lines = { "# KEYBINDS.md not found", filepath }
  end

  -- create scratch buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"

  -- mark this buffer as cheatsheet for resizing logic
  vim.api.nvim_buf_set_var(buf, "cheatsheet", true)

  -- compute size + position
  local function get_win_opts()
    local width = math.floor(vim.o.columns * 0.6)
    local height = math.floor(vim.o.lines * 0.7)
    local row = math.floor((vim.o.lines - height) / 2)
    local col = math.floor((vim.o.columns - width) / 2)

    return {
      relative = "editor",
      width = width,
      height = height,
      row = row,
      col = col,
      style = "minimal",
      border = "rounded",
      title = " Keybinds ",
      title_pos = "center",
    }
  end

  local win = vim.api.nvim_open_win(buf, true, get_win_opts())

  -- close on q or <Esc>
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, nowait = true })

  vim.keymap.set("n", "<Esc>", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, nowait = true })

  -- center the cursor and disable numbers
  vim.bo[buf].modifiable = false
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false

  -- auto-resize on VimResized
  local augroup = vim.api.nvim_create_augroup("CheatsheetResize", { clear = false })
  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = function()
      if not vim.api.nvim_win_is_valid(win) then
        return
      end
      local ok, is_cheatsheet = pcall(vim.api.nvim_buf_get_var, buf, "cheatsheet")
      if not ok or not is_cheatsheet then
        return
      end
      vim.api.nvim_win_set_config(win, get_win_opts())
    end,
  })
end

vim.keymap.set("n", "<leader>?", open_cheatsheet, { desc = "Keybind cheatsheet" })


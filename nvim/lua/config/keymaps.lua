local map = vim.keymap.set

---------------------------------------------------------------------
-- Diagnostics
---------------------------------------------------------------------
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev diagnostic" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })

---------------------------------------------------------------------
-- LSP
---------------------------------------------------------------------
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "gr", vim.lsp.buf.references, { desc = "References" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format" })

---------------------------------------------------------------------
-- Buffer management
---------------------------------------------------------------------
map("n", "<leader>q", "<cmd>bd<cr>", { desc = "Close buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })

---------------------------------------------------------------------
-- Splits
---------------------------------------------------------------------
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Horizontal split" })
map("n", "<leader>se", "<cmd>wincmd =<cr>", { desc = "Equalize splits" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close split" })

---------------------------------------------------------------------
-- Git
---------------------------------------------------------------------
map("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", { desc = "Toggle git blame" })

---------------------------------------------------------------------
-- Oil (file explorer)
---------------------------------------------------------------------
map("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File explorer" })
map("n", "-", "<cmd>Oil<cr>", { desc = "Open parent directory" })

---------------------------------------------------------------------
-- Undotree
---------------------------------------------------------------------
map("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Undo tree" })

---------------------------------------------------------------------
-- Cheatsheet popup (Space + ?)
---------------------------------------------------------------------
local function open_cheatsheet()
  local filepath = vim.fn.stdpath("config") .. "/KEYBINDS.md"

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

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_var(buf, "cheatsheet", true)

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

  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end, { buffer = buf, nowait = true })

  vim.keymap.set("n", "<Esc>", function()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end, { buffer = buf, nowait = true })

  vim.bo[buf].modifiable = false
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false

  local augroup = vim.api.nvim_create_augroup("CheatsheetResize", { clear = false })
  vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    callback = function()
      if not vim.api.nvim_win_is_valid(win) then return end
      local ok, is_cheatsheet = pcall(vim.api.nvim_buf_get_var, buf, "cheatsheet")
      if not ok or not is_cheatsheet then return end
      vim.api.nvim_win_set_config(win, get_win_opts())
    end,
  })
end

map("n", "<leader>?", open_cheatsheet, { desc = "Keybind cheatsheet" })

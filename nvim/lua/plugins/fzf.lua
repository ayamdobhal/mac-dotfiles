return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local fzf = require("fzf-lua")
    fzf.setup({
      winopts = {
        preview = { default = "bat" },
      },
    })

    local map = vim.keymap.set
    map("n", "<C-p>", fzf.files, { desc = "Find files" })
    map("n", "<D-p>", fzf.files, { desc = "Find files (Cmd+P)" })
    map("n", "<C-f>", fzf.blines, { desc = "Search in file" })
    map("n", "<D-f>", fzf.blines, { desc = "Search in file (Cmd+F)" })
    map("n", "<leader>sf", fzf.live_grep, { desc = "Search in project" })
    map("n", "<D-S-f>", fzf.live_grep, { desc = "Search in project (Cmd+Shift+F)" })
    map("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
    map("n", "<leader>fh", fzf.helptags, { desc = "Help" })
  end,
}

return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "Trouble",
  keys = {
    { "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>", desc = "Project diagnostics" },
    { "<leader>td", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer diagnostics" },
    { "<leader>to", "<cmd>Trouble todo toggle<cr>", desc = "TODOs" },
  },
  opts = {},
}

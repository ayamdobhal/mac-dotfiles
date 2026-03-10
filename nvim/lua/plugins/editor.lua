return {
  -- File explorer (edit filesystem like a buffer)
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("oil").setup({
        view_options = {
          show_hidden = true,
        },
      })
    end,
  },

  -- Surround text objects (cs"' to change quotes, ds" to delete, ysiw) to wrap)
  {
    "kylechui/nvim-surround",
    version = "^3",
    event = "VeryLazy",
    opts = {},
  },

  -- Auto-close brackets and quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },

  -- Auto-close and auto-rename HTML/JSX tags
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },

  -- Highlight TODO/FIXME/HACK/NOTE comments
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    opts = {},
  },

  -- Visual undo history tree
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
  },

  -- Quick file switching (mark files, jump between them instantly)
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      local map = vim.keymap.set
      map("n", "<leader>a", function() harpoon:list():add() end, { desc = "Harpoon add file" })
      map("n", "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Harpoon menu" })
      map("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Harpoon file 1" })
      map("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Harpoon file 2" })
      map("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Harpoon file 3" })
      map("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Harpoon file 4" })
    end,
  },
}

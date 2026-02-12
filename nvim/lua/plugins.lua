-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  ---------------------------------------------------------------------------
  -- 🌙 Tokyo Night Theme (Transparent)
  ---------------------------------------------------------------------------
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "storm",
        transparent = true,
        terminal_colors = true,
        styles = {
          sidebars = "transparent",
          floats = "transparent",
        },
      })
      vim.cmd("colorscheme tokyonight-storm")
    end,
  },

  ---------------------------------------------------------------------------
  -- 📍 Statusline
  ---------------------------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          theme = "tokyonight",
          section_separators = "",
          component_separators = "",
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 📁 File Explorer
  ---------------------------------------------------------------------------
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30 },
        filters = { dotfiles = false },
        renderer = { root_folder_label = false },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 🔍 Fuzzy Finder (Telescope)
  ---------------------------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",
            },
          },
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 🌈 Syntax Highlighting & Treesitter
  ---------------------------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua", "vim", "vimdoc",
          "rust", "elixir", "javascript", "typescript", "tsx",
          "html", "css", "json", "markdown", "markdown_inline",
          "python",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 🧠 LSP + Completion (New API)
  ---------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      ---------------------------------------------------------------------
      -- 💡 Autocomplete Setup
      ---------------------------------------------------------------------
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
      })

      ---------------------------------------------------------------------
      -- 🔧 LSP Servers (New vim.lsp.config API)
      ---------------------------------------------------------------------
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Rust
      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
      })

      -- Elixir (ensure `elixir-ls` exists in PATH)
      vim.lsp.config("elixirls", {
        cmd = { "elixir-ls" },
        capabilities = capabilities,
      })

      -- TypeScript / JavaScript / React
      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
      })

      -- Python (basedpyright via Homebrew)
      vim.lsp.config("basedpyright", {
        cmd = { "basedpyright-langserver", "--stdio" },
        capabilities = capabilities,
      })

      -- Enable all of them
      vim.lsp.enable({ "rust_analyzer", "elixirls", "ts_ls", "basedpyright" })
    end,
  },

  ---------------------------------------------------------------------------
  -- 🔨 Git Signs
  ---------------------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = false,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 300,
        },
        current_line_blame_formatter = "  <author> · <author_time:%Y-%m-%d> · <summary>",
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 🧱 Indent Guides & Scope Highlighting
  ---------------------------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope = {
          enabled = true,
          show_start = true,
          show_end = false,
        },
      })
    end,
  },

  ---------------------------------------------------------------------------
  -- 💬 Comment Toggle (Space + /)
  ---------------------------------------------------------------------------
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  ---------------------------------------------------------------------------
  -- ⌨️ Keybinding Helper
  ---------------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },
})


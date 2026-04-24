return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local parsers = {
      "lua", "vim", "vimdoc",
      "rust", "elixir", "javascript", "typescript", "tsx",
      "html", "css", "json", "markdown", "markdown_inline",
      "python",
    }

    require("nvim-treesitter").setup()

    local installed = require("nvim-treesitter.config").get_installed("parsers")
    local missing = vim.tbl_filter(function(p)
      return not vim.list_contains(installed, p)
    end, parsers)
    if #missing > 0 then
      require("nvim-treesitter").install(missing)
    end

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'vim.treesitter'.indentexpr()"
        end
      end,
    })
  end,
}

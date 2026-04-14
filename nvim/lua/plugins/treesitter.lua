return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").setup({
      ensure_installed = {
        "lua", "vim", "vimdoc",
        "rust", "elixir", "javascript", "typescript", "tsx",
        "html", "css", "json", "markdown", "markdown_inline",
        "python",
      },
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        if pcall(vim.treesitter.start, args.buf) then
          vim.bo[args.buf].indentexpr = "v:lua.require'vim.treesitter'.indentexpr()"
        end
      end,
    })
  end,
}

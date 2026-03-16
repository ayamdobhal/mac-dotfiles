return {
  {
    "newtoallofthis123/blink-cmp-fuzzy-path",
    dependencies = { "saghen/blink.cmp" },
    opts = {
      filetypes = { "markdown", "json" },
      trigger_char = "@",
      max_results = 5,
    },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    opts = {
      keymap = {
        preset = "default",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      },
      completion = {
        documentation = { auto_show = true },
      },
      sources = {
        default = { "fuzzy-path", "lsp", "path", "snippets", "buffer" },
        providers = {
          ["fuzzy-path"] = {
            name = "Fuzzy Path",
            module = "blink-cmp-fuzzy-path",
            score_offset = 0,
          },
        },
      },
    },
  },
}

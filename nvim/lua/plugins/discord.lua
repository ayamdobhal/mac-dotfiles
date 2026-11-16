-- "a Lua file" / "an HTML file"
local function article(name)
  name = name or "unknown"
  local a = name:sub(1, 1):lower():match("[aeiou]") and "an" or "a"
  return a .. " " .. name
end

return {
  "vyfor/cord.nvim",
  event = "VeryLazy",
  opts = {
    editor = {
      client = "neovim",
    },
    display = {
      theme = "minecraft",
      flavor = "accent",
      view = "full",
    },
    text = {
      -- empty string drops the workspace/repo line entirely
      workspace = "",
      editing = function(opts)
        return "Editing " .. article(opts.name) .. " file"
      end,
      viewing = function(opts)
        return "Viewing " .. article(opts.name) .. " file"
      end,
    },
  },
}

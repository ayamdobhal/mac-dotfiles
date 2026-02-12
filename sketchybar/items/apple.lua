local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Padding item required because of bracket
sbar.add("item", { width = 5 })

local apple = sbar.add("item", {
  icon = {
    font = { size = 16.0 },
    string = icons.apple,
    padding_right = 8,
    padding_left = 8,
  },
  label = { drawing = false },
  background = { drawing = false },
  padding_left = 1,
  padding_right = 1,
  click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0"
})

sbar.add("bracket", { apple.name }, {
  background = {
    color = colors.transparent,
    height = 30,
    border_width = 0,
  }
})

-- Padding item required because of bracket
sbar.add("item", { width = 7 })

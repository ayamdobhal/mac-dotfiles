local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

-- Execute the event provider binary which provides the event "cpu_update" for
-- the cpu load data, which is fired every 3.0 seconds.
sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 3.0")

local cpu = sbar.add("graph", "widgets.cpu" , 42, {
  position = "right",
  graph = { color = colors.blue },
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = { string = icons.cpu },
  label = {
    string = "cpu ??%",
    font = {
      family = settings.font.numbers,
      style = settings.font.style_map["Bold"],
      size = 9.0,
    },
    align = "right",
    padding_right = 0,
    width = 0,
    y_offset = 4
  },
  padding_right = settings.paddings + 6,
  popup = { align = "center", height = 30 }
})

local function load_color(load)
  if load > 80 then return colors.red
  elseif load > 60 then return colors.orange
  elseif load > 30 then return colors.yellow
  else return colors.blue end
end

-- Per-core popup graphs
local core_graphs = {}
local core_labels = {}
local num_cores = 0

local function ensure_core_items(n)
  if n <= num_cores then return end
  for i = num_cores + 1, n do
    local label = sbar.add("item", "cpu.core_label." .. i, {
      position = "popup." .. cpu.name,
      icon = {
        string = "Core " .. (i - 1),
        font = {
          family = settings.font.numbers,
          style = settings.font.style_map["Bold"],
          size = 10.0,
        },
        width = 50,
        align = "left",
      },
      label = {
        string = "??%",
        font = {
          family = settings.font.numbers,
          style = settings.font.style_map["Semibold"],
          size = 10.0,
        },
        width = 35,
        align = "right",
      },
      drawing = false,
    })

    local graph = sbar.add("graph", "cpu.core_graph." .. i, 30, {
      position = "popup." .. cpu.name,
      graph = { color = colors.blue },
      background = {
        height = 18,
        color = { alpha = 0 },
        border_color = { alpha = 0 },
        drawing = true,
      },
      icon = { drawing = false },
      label = { drawing = false },
      width = 120,
      padding_left = 0,
      padding_right = 0,
      drawing = false,
    })

    core_labels[i] = label
    core_graphs[i] = graph
  end
  num_cores = n
end

cpu:subscribe("cpu_update", function(env)
  local load = tonumber(env.total_load)
  cpu:push({ load / 100. })
  cpu:set({
    graph = { color = load_color(load) },
    label = { string = "cpu " .. load .. "%" }
  })

  -- Update per-core graphs if popup is open
  if not env.core_loads or env.core_loads == "" then return end
  local n = tonumber(env.num_cores) or 0
  if n == 0 then return end

  ensure_core_items(n)

  local i = 1
  for val in string.gmatch(env.core_loads, "([^,]+)") do
    if i > n then break end
    local core_load = tonumber(val) or 0
    core_graphs[i]:push({ core_load / 100. })
    core_graphs[i]:set({ graph = { color = load_color(core_load) } })
    core_labels[i]:set({ label = core_load .. "%" })
    i = i + 1
  end
end)

cpu:subscribe("mouse.clicked", function(env)
  local drawing = cpu:query().popup.drawing == "on"
  cpu:set({ popup = { drawing = "toggle" } })

  if not drawing then
    for i = 1, num_cores do
      core_labels[i]:set({ drawing = true })
      core_graphs[i]:set({ drawing = true })
    end
  end
end)

cpu:subscribe("mouse.exited.global", function()
  cpu:set({ popup = { drawing = "off" } })
end)

-- Background around the cpu item
sbar.add("bracket", "widgets.cpu.bracket", { cpu.name }, {
  background = { color = colors.bg1 }
})

-- Background around the cpu item
sbar.add("item", "widgets.cpu.padding", {
  position = "right",
  width = settings.group_paddings
})

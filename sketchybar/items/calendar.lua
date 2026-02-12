local settings = require("settings")
local colors = require("colors")

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

local cal_up = sbar.add("item", {
    position = "right",
    padding_left = 0,
    width = 0,
    label = {
      color = colors.white,
      padding_left = 8,
      padding_right = 8,
      font = {
        family = settings.font.numbers,
        size = 11.0
      }
    },
    y_offset = 6
  })

local cal_down = sbar.add("item", {
    position = "right",
    padding_left = 0,
    label = {
      color = colors.white,
      padding_left = 8,
      padding_right = 8,
      font = {
        family = settings.font.numbers,
        size = 11.0
      }
    },
    y_offset = -6
  })

local cal_bracket = sbar.add("bracket", { cal_up.name, cal_down.name }, {
  background = {
    color = colors.transparent,
    height = 30,
    border_width = 0,
  },
  update_freq = 1,
  popup = { align = "right", height = 30 }
})

-- Padding item required because of bracket
local spacing = sbar.add("item", { position = "right", width = 26 })

-- Calendar popup items
local cal_header = sbar.add("item", {
    position = "popup." .. cal_bracket.name,
    label = {
      string = "?",
      font = {
        family = settings.font.text,
        style = settings.font.style_map["Bold"],
        size = 13.0,
      },
      width = 200,
      align = "center",
      color = colors.white,
    },
    icon = { drawing = false },
    drawing = false,
})

local cal_weekdays = sbar.add("item", {
    position = "popup." .. cal_bracket.name,
    label = {
      string = " Su  Mo  Tu  We  Th  Fr  Sa",
      font = {
        family = settings.font.numbers,
        style = settings.font.style_map["Bold"],
        size = 11.0,
      },
      width = 200,
      align = "center",
      color = colors.grey,
    },
    icon = { drawing = false },
    drawing = false,
})

local cal_rows = {}
for i = 1, 6 do
    local row = sbar.add("item", {
        position = "popup." .. cal_bracket.name,
        label = {
          string = "",
          font = {
            family = settings.font.numbers,
            style = settings.font.style_map["Regular"],
            size = 11.0,
          },
          width = 200,
          align = "center",
          color = colors.white,
        },
        icon = { drawing = false },
        drawing = false,
    })
    cal_rows[i] = row
end

local function build_calendar()
    local now = os.date("*t")
    local year = now.year
    local month = now.month
    local today = now.day

    -- Month/Year header
    local header = os.date("%B %Y", os.time(now))
    cal_header:set({ label = { string = header }, drawing = true })
    cal_weekdays:set({ drawing = true })

    -- First day of month: wday (1=Sun, 2=Mon, ..., 7=Sat)
    local first = os.time({ year = year, month = month, day = 1 })
    local first_wday = tonumber(os.date("%w", first)) -- 0=Sun

    -- Days in month
    local next_month = os.time({ year = year, month = month + 1, day = 1 })
    local days_in_month = os.difftime(next_month, first) / 86400

    local row = 1
    local col = first_wday
    local lines = {}
    local line = string.rep("    ", col)

    for day = 1, days_in_month do
        if day == today then
            line = line .. string.format("[%2d]", day)
        else
            line = line .. string.format(" %2d ", day)
        end
        col = col + 1
        if col == 7 then
            lines[row] = line
            row = row + 1
            col = 0
            line = ""
        end
    end
    if line ~= "" then
        lines[row] = line
    end

    for i = 1, 6 do
        if lines[i] then
            cal_rows[i]:set({ label = { string = lines[i] }, drawing = true })
        else
            cal_rows[i]:set({ drawing = false })
        end
    end
end

cal_bracket:subscribe({ "forced", "routine", "system_woke" }, function(env)
    local up_value = string.format("%s %d", os.date("%a %b"), tonumber(os.date("%d")))
    if #up_value < 10 then
      spacing:set({ width = 18 })
    end
    local down_value = string.format("%d:%s:%s", tonumber(os.date("%H")), os.date("%M"), os.date("%S"))
    cal_up:set({ label = { string = up_value } })
    cal_down:set({ label = { string = down_value } })
  end)

local function toggle_calendar(env)
    local drawing = cal_bracket:query().popup.drawing == "on"
    cal_bracket:set({ popup = { drawing = "toggle" } })
    if not drawing then
        build_calendar()
    end
end

cal_up:subscribe("mouse.clicked", toggle_calendar)
cal_down:subscribe("mouse.clicked", toggle_calendar)

cal_bracket:subscribe("mouse.exited.global", function()
    cal_bracket:set({ popup = { drawing = "off" } })
end)

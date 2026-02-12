local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local popup_width = 200

local ram = sbar.add("graph", "widgets.ram", 42, {
    position = "right",
    graph = { color = colors.blue },
    background = {
        height = 22,
        color = { alpha = 0 },
        border_color = { alpha = 0 },
        drawing = true,
    },
    icon = { string = icons.ram },
    label = {
        string = "ram ??%",
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
    update_freq = 3,
    updates = true,
    padding_right = settings.paddings + 6,
    popup = { align = "center" }
})

local ram_total = sbar.add("item", {
    position = "popup." .. ram.name,
    icon = { string = "Total:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right" }
})

local ram_used = sbar.add("item", {
    position = "popup." .. ram.name,
    icon = { string = "Used:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right" }
})

local ram_free = sbar.add("item", {
    position = "popup." .. ram.name,
    icon = { string = "Free:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right" }
})

local ram_wired = sbar.add("item", {
    position = "popup." .. ram.name,
    icon = { string = "Wired:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right" }
})

local ram_active = sbar.add("item", {
    position = "popup." .. ram.name,
    icon = { string = "Active:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right" }
})

local ram_inactive = sbar.add("item", {
    position = "popup." .. ram.name,
    icon = { string = "Inactive:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right" }
})

local ram_compressed = sbar.add("item", {
    position = "popup." .. ram.name,
    icon = { string = "Compressed:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right" }
})

sbar.add("bracket", "widgets.ram.bracket", { ram.name }, {
    background = { color = colors.bg1 }
})
  
sbar.add("item", "widgets.ram.padding", {
    position = "right",
    width = settings.group_paddings
})

local function format_bytes(bytes)
    local gb = bytes / (1024 * 1024 * 1024)
    return string.format("%.2f GB", gb)
end

local function parse_vm_stat(output)
    local stats = {}
    local page_size = tonumber(output:match("page size of (%d+) bytes"))
    stats.free = tonumber(output:match("Pages free:%s+(%d+)")) * page_size
    stats.active = tonumber(output:match("Pages active:%s+(%d+)")) * page_size
    stats.inactive = tonumber(output:match("Pages inactive:%s+(%d+)")) * page_size
    stats.speculative = tonumber(output:match("Pages speculative:%s+(%d+)")) * page_size
    stats.wired = tonumber(output:match("Pages wired down:%s+(%d+)")) * page_size
    stats.compressed = tonumber(output:match("Pages occupied by compressor:%s+(%d+)")) * page_size
    stats.purgeable = tonumber(output:match("Pages purgeable:%s+(%d+)")) * page_size
    return stats
end

ram:subscribe({ "routine", "forced", "system_woke" }, function(env)
    sbar.exec("memory_pressure", function(output)
        local percentage = output:match("System%-wide memory free percentage: (%d+)")
        local load = 100 - tonumber(percentage)
        ram:push({ load / 100. })
        local color = colors.blue
        if load > 30 then
            if load < 60 then
                color = colors.yellow
            elseif load < 80 then
                color = colors.orange
            else
                color = colors.red
            end
        end
        ram:set({
            graph = { color = color },
            label = { string = "ram " .. load .. "%" }
        })
    end)
end)

ram:subscribe("mouse.clicked", function(env)
    local drawing = ram:query().popup.drawing
    ram:set({ popup = { drawing = "toggle" } })

    if drawing == "off" then
        sbar.exec("sysctl -n hw.memsize", function(total_mem)
            local total = tonumber(total_mem)
            ram_total:set({ label = format_bytes(total) })

            sbar.exec("vm_stat", function(vm_output)
                local stats = parse_vm_stat(vm_output)
                local used = stats.wired + stats.active + stats.compressed
                local free = stats.free + stats.inactive + stats.purgeable

                ram_used:set({ label = format_bytes(used) })
                ram_free:set({ label = format_bytes(free) })
                ram_wired:set({ label = format_bytes(stats.wired) })
                ram_active:set({ label = format_bytes(stats.active) })
                ram_inactive:set({ label = format_bytes(stats.inactive) })
                ram_compressed:set({ label = format_bytes(stats.compressed) })
            end)
        end)
    end
end)

ram:subscribe("mouse.exited.global", function()
    ram:set({ popup = { drawing = "off" } })
end)

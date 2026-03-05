local colors = require("colors")
local settings = require("settings")

local popup_width = 200

-- Curl command to fetch usage from the OAuth API
local usage_cmd = "curl -s --max-time 10 'https://api.anthropic.com/api/oauth/usage'"
    .. " -H 'Authorization: Bearer '$(security find-generic-password -s 'Claude Code-credentials' -w"
    .. " | /usr/bin/python3 -c \"import sys,re; m=re.search(r'\\\"accessToken\\\":\\\"([^\\\"]+)\\\"', sys.stdin.read()); print(m.group(1) if m else '')\")"
    .. " -H 'anthropic-beta: oauth-2025-04-20'"
    .. " -H 'Accept: application/json'"

local stats_cmd = "$CONFIG_DIR/helpers/claude_stats.sh"

local claude = sbar.add("item", "widgets.claude", {
    position = "right",
    icon = {
        string = "󰛄",
        font = {
            style = settings.font.style_map["Regular"],
            size = 19.0,
        },
        color = colors.magenta,
    },
    label = { font = { family = settings.font.numbers } },
    update_freq = 120,
    popup = { align = "center" },
})

-- Popup: rate limits
local popup_session = sbar.add("item", {
    position = "popup." .. claude.name,
    icon = { string = "Session (5hr):", width = popup_width / 2, align = "left" },
    label = { string = "??%", width = popup_width / 2, align = "right" },
})

local popup_session_resets = sbar.add("item", {
    position = "popup." .. claude.name,
    icon = {
        string = "  Resets in:",
        width = popup_width / 2,
        align = "left",
        font = { size = 9.0 },
        color = colors.grey,
    },
    label = {
        string = "??",
        width = popup_width / 2,
        align = "right",
        font = { size = 9.0 },
        color = colors.grey,
    },
})

local popup_weekly = sbar.add("item", {
    position = "popup." .. claude.name,
    icon = { string = "Weekly (7d):", width = popup_width / 2, align = "left" },
    label = { string = "??%", width = popup_width / 2, align = "right" },
})

local popup_weekly_resets = sbar.add("item", {
    position = "popup." .. claude.name,
    icon = {
        string = "  Resets in:",
        width = popup_width / 2,
        align = "left",
        font = { size = 9.0 },
        color = colors.grey,
    },
    label = {
        string = "??",
        width = popup_width / 2,
        align = "right",
        font = { size = 9.0 },
        color = colors.grey,
    },
})

-- Popup: live today stats from JSONL files
local popup_today_msgs = sbar.add("item", {
    position = "popup." .. claude.name,
    icon = { string = "Today Messages:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right" },
})

local popup_today_sessions = sbar.add("item", {
    position = "popup." .. claude.name,
    icon = { string = "Today Sessions:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right" },
})

local popup_today_tools = sbar.add("item", {
    position = "popup." .. claude.name,
    icon = { string = "Today Tool Calls:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right" },
})

-- Popup: estimated cost (from token usage)
local popup_cost_daily = sbar.add("item", {
    position = "popup." .. claude.name,
    icon = { string = "Cost Today:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right", color = colors.green },
})

local popup_cost_weekly = sbar.add("item", {
    position = "popup." .. claude.name,
    icon = { string = "Cost Weekly:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right", color = colors.green },
})

local popup_cost_monthly = sbar.add("item", {
    position = "popup." .. claude.name,
    icon = { string = "Cost Monthly:", width = popup_width / 2, align = "left" },
    label = { string = "??", width = popup_width / 2, align = "right", color = colors.green },
})

sbar.add("bracket", "widgets.claude.bracket", { claude.name }, {
    background = { color = colors.bg1 },
})

sbar.add("item", "widgets.claude.padding", {
    position = "right",
    width = settings.group_paddings,
})

local function usage_color(pct)
    if pct >= 80 then return colors.red
    elseif pct >= 60 then return colors.orange
    elseif pct >= 30 then return colors.yellow
    else return colors.green end
end

local function parse_reset_time(iso_str)
    if not iso_str or iso_str == "" then return "??" end
    local year, month, day, hour, min, sec = iso_str:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    if not hour then return "??" end

    local utc_time = os.time({
        year = tonumber(year), month = tonumber(month), day = tonumber(day),
        hour = tonumber(hour), min = tonumber(min), sec = tonumber(sec),
    })
    local local_t = os.date("*t", utc_time)
    local utc_t = os.date("!*t", utc_time)
    local offset = os.time(local_t) - os.time(utc_t)
    local local_epoch = utc_time + offset

    local now = os.time()
    local diff = local_epoch - now
    if diff < 0 then return "now" end

    if diff < 3600 then
        return string.format("%dm", math.floor(diff / 60))
    elseif diff < 86400 then
        return string.format("%dh %dm", math.floor(diff / 3600), math.floor((diff % 3600) / 60))
    else
        return os.date("%b %d %H:%M", local_epoch)
    end
end

local function fetch_usage(callback)
    sbar.exec(usage_cmd, function(result)
        if not result or result == "" then
            callback(nil)
            return
        end
        callback(result)
    end)
end

local function update_bar(data)
    if not data then
        claude:set({ label = { string = "N/A" } })
        return
    end

    local session_pct = 0
    if data.five_hour then
        session_pct = math.floor(data.five_hour.utilization or 0)
    end

    claude:set({
        label = { string = session_pct .. "%" },
        icon = { color = usage_color(session_pct) },
    })
end

local function update_popup(data)
    if not data then return end

    -- Session (5hr)
    local session_pct = 0
    local session_reset = "??"
    if data.five_hour then
        session_pct = math.floor(data.five_hour.utilization or 0)
        session_reset = parse_reset_time(data.five_hour.resets_at)
    end
    popup_session:set({
        label = {
            string = session_pct .. "%",
            color = usage_color(session_pct),
        },
    })
    popup_session_resets:set({ label = session_reset })

    -- Weekly (7d)
    local weekly_pct = 0
    local weekly_reset = "??"
    if data.seven_day then
        weekly_pct = math.floor(data.seven_day.utilization or 0)
        weekly_reset = parse_reset_time(data.seven_day.resets_at)
    end
    popup_weekly:set({
        label = {
            string = weekly_pct .. "%",
            color = usage_color(weekly_pct),
        },
    })
    popup_weekly_resets:set({ label = weekly_reset })

    -- Live stats from JSONL files
    sbar.exec(stats_cmd, function(result)
        if not result or result == "" then return end
        local sessions, messages, tool_calls, cost_d, cost_w, cost_m =
            result:match("(%d+)|(%d+)|(%d+)|([%d%.]+)|([%d%.]+)|([%d%.]+)")
        if sessions then
            popup_today_sessions:set({ label = sessions })
            popup_today_msgs:set({ label = messages })
            popup_today_tools:set({ label = tool_calls })
            popup_cost_daily:set({ label = { string = "$" .. cost_d, color = colors.green } })
            popup_cost_weekly:set({ label = { string = "$" .. cost_w, color = colors.green } })
            popup_cost_monthly:set({ label = { string = "$" .. cost_m, color = colors.green } })
        end
    end)
end

claude:subscribe({ "routine", "forced", "system_woke" }, function()
    fetch_usage(function(data)
        update_bar(data)
    end)
end)

claude:subscribe("mouse.clicked", function()
    local drawing = claude:query().popup.drawing
    claude:set({ popup = { drawing = "toggle" } })
    if drawing == "off" then
        fetch_usage(function(data)
            update_popup(data)
        end)
    end
end)

claude:subscribe("mouse.exited.global", function()
    claude:set({ popup = { drawing = "off" } })
end)

-- Initial load
fetch_usage(function(data)
    update_bar(data)
end)

local colors = require("colors")
local settings = require("settings")

local popup_width = 260
local popup_label_width = 145
local popup_value_width = popup_width - popup_label_width

-- Curl command to fetch Claude Code usage limits from the OAuth API.
local usage_cmd = "curl -s --max-time 10 'https://api.anthropic.com/api/oauth/usage'"
    .. " -H 'Authorization: Bearer '$(security find-generic-password -s 'Claude Code-credentials' -w"
    .. " | /usr/bin/python3 -c \"import sys,re; m=re.search(r'\\\"accessToken\\\":\\\"([^\\\"]+)\\\"', sys.stdin.read()); print(m.group(1) if m else '')\")"
    .. " -H 'anthropic-beta: oauth-2025-04-20'"
    .. " -H 'Accept: application/json'"

local stats_cmd = "$CONFIG_DIR/helpers/claude_stats.sh"
local app_icon_font = "sketchybar-app-font:Regular:16.0"
local claude_logo_color = colors.orange
local codex_logo_color = colors.green

local claude = sbar.add("item", "widgets.claude", {
    position = "right",
    icon = {
        string = ":claude:",
        font = app_icon_font,
        color = claude_logo_color,
        padding_right = 2,
    },
    label = { font = { family = settings.font.numbers } },
    update_freq = 300,
    popup = { align = "center" },
})

local codex = sbar.add("item", "widgets.codex", {
    position = "right",
    icon = {
        string = ":openai:",
        font = app_icon_font,
        color = codex_logo_color,
        padding_left = 6,
        padding_right = 2,
    },
    label = { font = { family = settings.font.numbers } },
    update_freq = 300,
})

local function add_header(title, color)
    return sbar.add("item", {
        position = "popup." .. claude.name,
        icon = {
            string = title,
            width = popup_width,
            align = "left",
            color = color,
            font = {
                style = settings.font.style_map["Semibold"],
                size = 10.0,
            },
        },
        label = { string = "", width = 0 },
    })
end

local function add_row(label, initial, opts)
    opts = opts or {}
    return sbar.add("item", {
        position = "popup." .. claude.name,
        icon = {
            string = label,
            width = popup_label_width,
            align = "left",
            color = opts.icon_color or colors.white,
            font = opts.icon_font,
        },
        label = {
            string = initial or "??",
            width = popup_value_width,
            align = "right",
            color = opts.label_color or colors.white,
            font = opts.label_font or { family = settings.font.numbers },
        },
    })
end

local subrow_icon = {
    size = 9.0,
}

local subrow_label = {
    family = settings.font.numbers,
    size = 9.0,
}

add_header("Claude", claude_logo_color)
local popup_claude_session = add_row("Session (5hr):", "??%")
local popup_claude_session_reset = add_row("  Resets in:", "??", {
    icon_color = colors.grey,
    label_color = colors.grey,
    icon_font = subrow_icon,
    label_font = subrow_label,
})
local popup_claude_weekly = add_row("Weekly (7d):", "??%")
local popup_claude_weekly_reset = add_row("  Resets in:", "??", {
    icon_color = colors.grey,
    label_color = colors.grey,
    icon_font = subrow_icon,
    label_font = subrow_label,
})
local popup_claude_tokens = add_row("30d Tokens:", "??")
local popup_claude_cost = add_row("30d Cost:", "??", { label_color = colors.green })
local popup_claude_activity = add_row("30d Sessions:", "??")
local popup_claude_model = add_row("Model:", "??", { label_color = colors.grey })

add_header("Codex", codex_logo_color)
local popup_codex_session = add_row("Session (5hr):", "??")
local popup_codex_session_reset = add_row("  Resets in:", "??", {
    icon_color = colors.grey,
    label_color = colors.grey,
    icon_font = subrow_icon,
    label_font = subrow_label,
})
local popup_codex_weekly = add_row("Weekly (7d):", "??")
local popup_codex_weekly_reset = add_row("  Resets in:", "??", {
    icon_color = colors.grey,
    label_color = colors.grey,
    icon_font = subrow_icon,
    label_font = subrow_label,
})
local popup_codex_credit_limit = add_row("Credit Limit:", "??", { label_color = colors.green })
local popup_codex_tokens = add_row("30d Tokens:", "??")
local popup_codex_cost = add_row("30d Cost:", "??", { label_color = colors.green })
local popup_codex_activity = add_row("30d Sessions:", "??")
local popup_codex_model = add_row("Model/Plan:", "??", { label_color = colors.grey })

sbar.add("bracket", "widgets.claude.bracket", { claude.name, codex.name }, {
    background = { color = colors.bg1 },
})

sbar.add("item", "widgets.claude.padding", {
    position = "right",
    width = settings.group_paddings,
})

local function usage_color(pct)
    pct = tonumber(pct) or 0
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

local function parse_stats(result)
    if not result or result == "" then return nil end
    local stats = {}
    for line in result:gmatch("[^\r\n]+") do
        local key, value = line:match("^([%w_]+)=(.*)$")
        if key then
            stats[key] = value
        end
    end
    if next(stats) == nil then return nil end
    return stats
end

local function compact_number(value)
    local n = tonumber(value) or 0
    local abs_n = math.abs(n)
    if abs_n >= 1000000000 then
        return string.format("%.2fB", n / 1000000000)
    elseif abs_n >= 1000000 then
        return string.format("%.1fM", n / 1000000)
    elseif abs_n >= 1000 then
        return string.format("%.1fk", n / 1000)
    else
        return tostring(math.floor(n + 0.5))
    end
end

local function format_usd(value)
    return "$" .. string.format("%.2f", tonumber(value) or 0)
end

local function percent_label(value, fallback)
    if value and value ~= "" then
        return string.format("%d%%", math.floor((tonumber(value) or 0) + 0.5))
    end
    return fallback or "n/a"
end

local function reset_label(value)
    if value and value ~= "" then return value end
    return "n/a"
end

local function set_label(item, value, color)
    item:set({
        label = {
            string = value,
            color = color,
        },
    })
end

local last_usage = nil
local last_stats = nil

local function fetch_usage(callback)
    sbar.exec(usage_cmd, function(result)
        if not result or result == "" then
            callback(last_usage)
            return
        end
        if result.error then
            callback(last_usage)
            return
        end
        last_usage = result
        callback(result)
    end)
end

local function fetch_stats(callback)
    sbar.exec(stats_cmd, function(result)
        local stats = parse_stats(result)
        if stats then
            last_stats = stats
        end
        callback(last_stats)
    end)
end

local function claude_session_pct(data)
    if data and data.five_hour then
        return math.floor(data.five_hour.utilization or 0)
    end
    return nil
end

local function update_bar(_, stats)
    if not stats then
        claude:set({ label = { string = "N/A" } })
        codex:set({ label = { string = "N/A" } })
        return
    end

    claude:set({
        icon = { color = claude_logo_color },
        label = { string = compact_number(stats.claude_total_tokens) },
    })
    codex:set({
        icon = { color = codex_logo_color },
        label = { string = compact_number(stats.codex_total_tokens) },
    })
end

local function update_claude_popup(data)
    local session_pct = 0
    local session_reset = "??"
    if data and data.five_hour then
        session_pct = math.floor(data.five_hour.utilization or 0)
        session_reset = parse_reset_time(data.five_hour.resets_at)
    end
    set_label(popup_claude_session, session_pct .. "%", usage_color(session_pct))
    set_label(popup_claude_session_reset, session_reset, colors.grey)

    local weekly_pct = 0
    local weekly_reset = "??"
    if data and data.seven_day then
        weekly_pct = math.floor(data.seven_day.utilization or 0)
        weekly_reset = parse_reset_time(data.seven_day.resets_at)
    end
    set_label(popup_claude_weekly, weekly_pct .. "%", usage_color(weekly_pct))
    set_label(popup_claude_weekly_reset, weekly_reset, colors.grey)
end

local function update_stats_popup(stats)
    if not stats then return end

    set_label(popup_claude_tokens, compact_number(stats.claude_total_tokens))
    set_label(popup_claude_cost, format_usd(stats.claude_cost_usd), colors.green)
    set_label(popup_claude_activity, compact_number(stats.claude_sessions))
    set_label(popup_claude_model, stats.claude_model or "n/a", colors.grey)

    local codex_limit_fallback = stats.codex_credit_status == "unlimited" and "unlimited" or "n/a"
    local codex_session = percent_label(stats.codex_primary_pct, codex_limit_fallback)
    local codex_weekly = percent_label(stats.codex_secondary_pct, codex_limit_fallback)
    local codex_session_color = stats.codex_primary_pct ~= "" and usage_color(stats.codex_primary_pct) or colors.green
    local codex_weekly_color = stats.codex_secondary_pct ~= "" and usage_color(stats.codex_secondary_pct) or colors.green

    set_label(popup_codex_session, codex_session, codex_session_color)
    set_label(popup_codex_session_reset, reset_label(stats.codex_primary_reset), colors.grey)
    set_label(popup_codex_weekly, codex_weekly, codex_weekly_color)
    set_label(popup_codex_weekly_reset, reset_label(stats.codex_secondary_reset), colors.grey)
    set_label(popup_codex_credit_limit, stats.codex_credit_status or "n/a", colors.green)
    set_label(popup_codex_tokens, compact_number(stats.codex_total_tokens))
    set_label(popup_codex_cost, format_usd(stats.codex_cost_usd), colors.green)
    set_label(popup_codex_activity, compact_number(stats.codex_sessions))
    set_label(popup_codex_model, (stats.codex_model or "n/a") .. " / " .. (stats.codex_plan or "n/a"), colors.grey)
end

local function refresh_bar()
    fetch_usage(function(data)
        fetch_stats(function(stats)
            update_bar(data, stats)
        end)
    end)
end

local function refresh_popup()
    fetch_usage(function(data)
        update_claude_popup(data)
        fetch_stats(function(stats)
            update_stats_popup(stats)
            update_bar(data, stats)
        end)
    end)
end

claude:subscribe({ "routine", "forced", "system_woke" }, refresh_bar)

claude:subscribe("mouse.clicked", function()
    local drawing = claude:query().popup.drawing
    claude:set({ popup = { drawing = "toggle" } })
    if drawing == "off" then
        refresh_popup()
    end
end)

codex:subscribe("mouse.clicked", function()
    local drawing = claude:query().popup.drawing
    claude:set({ popup = { drawing = "toggle" } })
    if drawing == "off" then
        refresh_popup()
    end
end)

claude:subscribe("mouse.exited.global", function()
    claude:set({ popup = { drawing = "off" } })
end)

codex:subscribe("mouse.exited.global", function()
    claude:set({ popup = { drawing = "off" } })
end)

refresh_bar()

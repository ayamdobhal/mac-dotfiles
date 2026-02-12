local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local loc = require("utils.loc")
local tbl = require("utils.tbl")

local weather = sbar.add("item", "widgets.weather", {
    position = "right",
    icon = { drawing = false },
    label = {
        string = icons.loading,
        font = { family = settings.font.numbers }
    },
    update_freq = 1800,
    popup = { align = "center", height = 25 }
})

sbar.add("bracket", "widgets.weather.bracket", { weather.name }, {
    background = { color = colors.bg1 }
})

sbar.add("item", "widgets.weather.padding", {
    position = "right",
    width = settings.group_paddings
})

local location_info = sbar.add("item", {
    position = "popup." .. weather.name,
    label = {
      string = "No weather data",
      width = 160,
      align = "left",
      font = { size = 10.0 }
    },
    drawing = true
})

local popup_days = {}
for i = 1, 3 do
    local popup_hours = {}
    local item = sbar.add("item", {
        position = "popup." .. weather.name,
        label = {
          string = "?",
          width = 160,
          align = "left"
        },
        drawing = false
      })
    for j = 1, 8 do
        local hour_item = sbar.add("item", {
            position = "popup." .. weather.name,
            icon = {
              string = "?",
              width = 25,
              align = "left"
            },
            label = {
              string = "?",
              width = 135,
              align = "left"
            },
            drawing = false
          })
        table.insert(popup_hours, hour_item)
    end
    local popup_value = {
        day_value = item,
        hour_values = popup_hours
    }
    table.insert(popup_days, popup_value)
end

-- WMO weather code to icon mapping (used by Open-Meteo)
local function wmo_code_to_icon(code)
    if code == 0 then return icons.weather.sunny
    elseif code == 1 then return icons.weather.sunny
    elseif code == 2 then return icons.weather.partly
    elseif code == 3 then return icons.weather.cloudy
    elseif code >= 45 and code <= 48 then return icons.weather.foggy
    elseif code >= 51 and code <= 55 then return icons.weather.rainy
    elseif code >= 56 and code <= 57 then return icons.weather.sleet
    elseif code >= 61 and code <= 65 then return icons.weather.rainy
    elseif code >= 66 and code <= 67 then return icons.weather.sleet
    elseif code >= 71 and code <= 77 then return icons.weather.snowy
    elseif code >= 80 and code <= 82 then return icons.weather.rainy
    elseif code >= 85 and code <= 86 then return icons.weather.snowy
    elseif code >= 95 and code <= 99 then return icons.weather.stormy
    end
    return "?"
end

-- wttr.in condition string to icon mapping (fallback)
local function map_condition_to_icon(cond)
    local condition = cond:lower():match("^%s*(.-)%s*$")
    if condition == "sunny" then
        return icons.weather.sunny
    elseif condition == "cloudy" or condition == "overcast" or condition == "haze" then
        return icons.weather.cloudy
    elseif condition == "clear" then
        return icons.weather.clear
    elseif string.find(condition, "storm") or string.find(condition, "thunder") then
        return icons.weather.stormy
    elseif string.find(condition, "partly") then
        return icons.weather.partly
    elseif string.find(condition, "sleet") or string.find(condition, "freez") then
        return icons.weather.sleet
    elseif string.find(condition, "rain") or string.find(condition, "drizzle") then
        return icons.weather.rainy
    elseif string.find(condition, "snow") or string.find(condition, "ice") then
        return icons.weather.snowy
    elseif string.find(condition, "mist") or string.find(condition, "fog") then
        return icons.weather.foggy
    end
    return "?"
end

-- Open-Meteo data loader
local function load_open_meteo(data, loc_name)
    local temp = math.floor(data.current.temperature_2m + 0.5)
    local code = data.current.weather_code
    weather:set({
        icon = { string = wmo_code_to_icon(code), drawing = true },
        label = { string = temp .. "°" }
    })

    location_info:set({ label = { string = loc_name } })

    local times = data.hourly.time
    local temps = data.hourly.temperature_2m
    local codes = data.hourly.weather_code
    local precip = data.hourly.precipitation_probability

    local current_time = os.date("*t")
    local current_hour = current_time.hour

    for day_index = 1, 3 do
        local display_date = "Today"
        if day_index == 2 then
            display_date = "Tomorrow"
        elseif day_index == 3 then
            local two_days_later = os.time() + (2 * 24 * 60 * 60)
            display_date = tostring(os.date("%A", two_days_later))
        end
        popup_days[day_index].day_value:set({ label = { string = display_date }, drawing = true })

        local slot = 1
        for h = 0, 21, 3 do
            local idx = ((day_index - 1) * 24) + h + 1
            if idx <= #times then
                if day_index == 1 and h < (current_hour - 3) then
                    popup_days[day_index].hour_values[slot]:set({ drawing = false })
                else
                    local hour_str = string.format("%02d:00", h)
                    local t = math.floor(temps[idx] + 0.5)
                    local p = precip[idx] or 0
                    local c = codes[idx] or 0
                    popup_days[day_index].hour_values[slot]:set({
                        icon = { string = wmo_code_to_icon(c) },
                        label = { string = hour_str .. " | " .. t .. "°" .. " | " .. p .. "%" },
                        drawing = true
                    })
                end
            else
                popup_days[day_index].hour_values[slot]:set({ drawing = false })
            end
            slot = slot + 1
        end
    end
end

-- wttr.in data loader (fallback)
local function load_wttr(weather_data)
    local current_condition = weather_data.current_condition[1]
    local temperature = current_condition.temp_C .. "°"
    local condition = current_condition.weatherDesc[1].value
    weather:set({
        icon = { string = map_condition_to_icon(condition), drawing = true },
        label = { string = temperature }
    })
    local nearest_area = weather_data.nearest_area[1]
    local city = nearest_area.areaName[1].value
    local country = nearest_area.country[1].value
    local region = country == "United States of America" and nearest_area.region[1].value or country
    location_info:set({ label = { string = city .. ", " .. region } })

    local current_time = os.date("*t")
    local time_number = current_time.hour * 100 + current_time.min
    for day_index, day_item in pairs(weather_data.weather) do
        local display_date = "Today"
        if day_index == 2 then
            display_date = "Tomorrow"
        elseif day_index == 3 then
            local two_days_later = os.time() + (2 * 24 * 60 * 60)
            display_date = tostring(os.date("%A", two_days_later))
        end
        popup_days[day_index].day_value:set({ label = { string = display_date }, drawing = true })
        for hourly_index, hourly_item in ipairs(day_item.hourly) do
            if day_index == 1 and time_number > tonumber(hourly_item.time) + 300 then
                popup_days[day_index].hour_values[hourly_index]:set({ drawing = false })
            else
                local hours = math.floor(tonumber(hourly_item.time) / 100)
                local mins = hourly_item.time % 100
                local time_str = string.format("%02d:%02d", hours, mins)
                popup_days[day_index].hour_values[hourly_index]:set({
                    icon = { string = map_condition_to_icon(hourly_item.weatherDesc[1].value) },
                    label = { string = time_str .. " | " .. hourly_item.tempC .. "°" .. " | " .. (100 - tonumber(hourly_item.chanceofremdry)) .. "%" },
                    drawing = true
                })
            end
        end
    end
end

-- Resolve location name from coordinates via Open-Meteo geocoding (reverse)
local function fetch_open_meteo(lat, lon, loc_name)
    local url = "https://api.open-meteo.com/v1/forecast?"
              .. "latitude=" .. lat .. "&longitude=" .. lon
              .. "&current=temperature_2m,weather_code"
              .. "&hourly=temperature_2m,weather_code,precipitation_probability"
              .. "&timezone=auto&forecast_days=3"
    sbar.exec("curl -s --max-time 10 '" .. url .. "'", function(result)
        if result == "" then
            -- Open-Meteo failed, fall back to wttr.in
            local wttr_loc = settings.weather.location or ""
            sbar.exec("curl -s --max-time 10 'https://wttr.in/" .. wttr_loc .. "?format=j1'", function(wttr_result)
                if wttr_result ~= "" then load_wttr(wttr_result) end
            end)
            return
        end
        load_open_meteo(result, loc_name)
    end)
end

-- Geocode a location name to lat/lon, then fetch weather
local function geocode_and_fetch(loc_name)
    local encoded = loc_name:gsub(" ", "%%20")
    local url = "https://geocoding-api.open-meteo.com/v1/search?name=" .. encoded .. "&count=1"
    sbar.exec("curl -s --max-time 10 '" .. url .. "'", function(result)
        if result == "" or not result.results or #result.results == 0 then
            -- Geocoding failed, fall back to wttr.in
            local wttr_loc = settings.weather.location or ""
            sbar.exec("curl -s --max-time 10 'https://wttr.in/" .. wttr_loc .. "?format=j1'", function(wttr_result)
                if wttr_result ~= "" then load_wttr(wttr_result) end
            end)
            return
        end
        local r = result.results[1]
        local display = r.name .. ", " .. (r.admin1 or r.country)
        fetch_open_meteo(r.latitude, r.longitude, display)
    end)
end

weather:subscribe({"routine", "forced", "system_woke"}, function ()
    if settings.weather.use_shortcut then
        sbar.exec("ipconfig getifaddr en0", function (wifi)
            if wifi ~= "" then
                sbar.exec("shortcuts run \"Get Location\" | tee", function (location)
                    local loc_name = ""
                    local loc_tbl = tbl.from_string(location)
                    if loc_tbl and #loc_tbl > 0 then
                        loc_name = loc_tbl[1]
                    end
                    if loc_name ~= "" then
                        geocode_and_fetch(loc_name)
                    elseif settings.weather.location then
                        geocode_and_fetch(settings.weather.location)
                    else
                        geocode_and_fetch("Mumbai")
                    end
                end)
            elseif settings.weather.location then
                geocode_and_fetch(settings.weather.location)
            else
                geocode_and_fetch("Mumbai")
            end
        end)
    elseif settings.weather.location then
        geocode_and_fetch(settings.weather.location)
    else
        geocode_and_fetch("Mumbai")
    end
  end)

weather:subscribe("mouse.clicked", function()
    weather:set({ popup = { drawing = "toggle" }})
end)

weather:subscribe("mouse.exited.global", function()
    weather:set({ popup = { drawing = "off" }})
end)

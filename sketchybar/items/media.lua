local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local token_script = os.getenv("CONFIG_DIR") .. "/helpers/spotify_token.sh"
local art_cache_dir = "/tmp/sketchybar_spotify"
local art_size = 28
local popup_art_size = 80
local spotify_green = 0xff1db954

sbar.exec("mkdir -p " .. art_cache_dir)

-- ── Token Management ──────────────────────────────────────────────
local cached_token = nil

local function get_token(callback)
  if cached_token then
    callback(cached_token)
    return
  end
  sbar.exec("bash " .. token_script, function(result)
    if type(result) ~= "string" then
      callback(nil)
      return
    end
    local token = result:gsub("%s+$", "")
    if token == "" or token:match("^ERROR:") then
      callback(nil)
      return
    end
    cached_token = token
    -- Expire local cache after 50 minutes
    sbar.delay(3000, function() cached_token = nil end)
    callback(token)
  end)
end

local function invalidate_token(callback)
  cached_token = nil
  sbar.exec(
    "security delete-generic-password -a spotify -s spotify_access_token 2>/dev/null;"
    .. " security delete-generic-password -a spotify -s spotify_token_expiry 2>/dev/null;"
    .. " echo done",
    function()
      get_token(callback)
    end
  )
end

local function build_curl(token, method, endpoint, body)
  local cmd = "HTTP_CODE=$(curl -s -o /tmp/sketchybar_spotify_resp -w '%{http_code}' --max-time 10"
    .. " -X " .. method
    .. " -H 'Authorization: Bearer " .. token .. "'"
    .. " -H 'Content-Type: application/json'"
  if body then
    cmd = cmd .. " -d '" .. body .. "'"
  end
  cmd = cmd .. " 'https://api.spotify.com" .. endpoint .. "')"
  cmd = cmd .. " && echo \"STATUS:$HTTP_CODE\" && cat /tmp/sketchybar_spotify_resp"
  return cmd
end

local function parse_api_result(result)
  if type(result) ~= "string" then return "", 0 end
  local status = 0
  local body = ""
  local status_line = result:match("STATUS:(%d+)")
  if status_line then
    status = tonumber(status_line) or 0
    body = result:match("STATUS:%d+\n(.*)") or ""
  end
  return body, status
end

local function spotify_api(method, endpoint, callback, body)
  get_token(function(token)
    if not token then
      if callback then callback(nil, 0) end
      return
    end
    sbar.exec(build_curl(token, method, endpoint, body), function(result)
      local response_body, status = parse_api_result(result)

      if status == 401 then
        invalidate_token(function(new_token)
          if not new_token then
            if callback then callback(nil, 401) end
            return
          end
          sbar.exec(build_curl(new_token, method, endpoint, body), function(retry_result)
            local rb, rc = parse_api_result(retry_result)
            if callback then callback(rb, rc) end
          end)
        end)
        return
      end

      if callback then callback(response_body, status) end
    end)
  end)
end

-- ── Collapsed State (Bar Items) ───────────────────────────────────
local media_cover = sbar.add("item", "media.cover", {
  position = "right",
  background = {
    image = { scale = 0.8, corner_radius = 5 },
    color = colors.bg2,
    height = art_size,
    corner_radius = 5,
    border_width = 0,
    drawing = true,
  },
  icon = {
    string = icons.media.spotify,
    color = colors.grey,
    font = { size = 14.0 },
    width = art_size,
    align = "center",
    padding_left = 0,
    padding_right = 0,
  },
  label = { drawing = false },
  drawing = true,
  width = art_size,
  padding_right = 3,
  padding_left = 3,
  popup = {
    align = "center",
    horizontal = false,
  },
})

local media_artist = sbar.add("item", "media.artist", {
  position = "right",
  drawing = true,
  padding_left = 5,
  padding_right = 0,
  width = 0,
  icon = { drawing = false },
  label = {
    width = 0,
    font = { size = 9 },
    color = colors.with_alpha(colors.white, 0.6),
    max_chars = 20,
    y_offset = 6,
  },
  scroll_texts = true,
})

local media_title = sbar.add("item", "media.title", {
  position = "right",
  drawing = true,
  padding_left = 0,
  padding_right = 5,
  icon = { drawing = false },
  label = {
    font = { size = 11 },
    width = 0,
    max_chars = 18,
    y_offset = -5,
  },
  scroll_texts = true,
})

local media_bracket = sbar.add("bracket", "media.bracket", {
  media_cover.name,
  media_artist.name,
  media_title.name,
}, {
  background = { color = colors.bg1 },
})

sbar.add("item", "media.padding", {
  position = "right",
  width = settings.group_paddings,
})

-- ── Popup Items ───────────────────────────────────────────────────
sbar.add("item", "media.popup_spacer_top", {
  position = "popup." .. media_cover.name,
  icon = { drawing = false },
  label = { drawing = false },
  width = 200,
  height = 8,
})

local popup_art = sbar.add("item", "media.popup_art", {
  position = "popup." .. media_cover.name,
  background = {
    image = { scale = 0.125, corner_radius = 8 },
    color = colors.bg2,
    height = popup_art_size,
    corner_radius = 8,
    border_width = 0,
    drawing = true,
  },
  icon = {
    string = icons.media.spotify,
    color = colors.grey,
    font = { size = 32.0 },
    width = popup_art_size,
    align = "center",
  },
  label = { drawing = false },
  width = popup_art_size,
  height = popup_art_size,
  padding_left = 60,
  padding_right = 60,
})

local popup_track = sbar.add("item", "media.popup_track", {
  position = "popup." .. media_cover.name,
  icon = { drawing = false },
  label = {
    font = {
      style = settings.font.style_map["Semibold"],
      size = 12.0,
    },
    color = colors.white,
    max_chars = 30,
    width = 200,
    align = "center",
  },
  background = { height = 18 },
  width = 200,
  scroll_texts = false,
  padding_left = 0,
  padding_right = 0,
})

local popup_artist = sbar.add("item", "media.popup_artist", {
  position = "popup." .. media_cover.name,
  icon = { drawing = false },
  label = {
    font = { size = 10.0 },
    color = colors.with_alpha(colors.white, 0.6),
    max_chars = 35,
    width = 200,
    align = "center",
  },
  background = { height = 14 },
  width = 200,
  scroll_texts = false,
  padding_left = 0,
  padding_right = 0,
})

local popup_album = sbar.add("item", "media.popup_album", {
  position = "popup." .. media_cover.name,
  icon = { drawing = false },
  label = {
    font = { size = 9.0 },
    color = colors.with_alpha(colors.grey, 0.5),
    max_chars = 40,
    width = 200,
    align = "center",
  },
  background = { height = 12 },
  width = 200,
  scroll_texts = false,
  padding_left = 0,
  padding_right = 0,
})

local function controls_string(play_icon)
  return icons.media.back .. "      " .. play_icon .. "      " .. icons.media.forward
end

local popup_controls = sbar.add("item", "media.popup_controls", {
  position = "popup." .. media_cover.name,
  icon = {
    string = controls_string(icons.media.play),
    font = { size = 18.0 },
    color = colors.white,
    width = 200,
    align = "center",
  },
  label = { drawing = false },
  width = 200,
  padding_left = 0,
  padding_right = 0,
})

local popup_devices_header = sbar.add("item", "media.popup_devices_header", {
  position = "popup." .. media_cover.name,
  icon = { drawing = false },
  label = {
    string = "─── Devices ───",
    font = { size = 10.0 },
    color = colors.with_alpha(colors.grey, 0.5),
    width = 200,
    align = "center",
  },
  width = 200,
  padding_left = 0,
  padding_right = 0,
})

-- ── State ─────────────────────────────────────────────────────────
local last_track = ""
local is_playing = false
local current_art_small = ""
local current_art_large = ""
local popup_is_open = false

-- ── Hover Animation ───────────────────────────────────────────────
local interrupt = 0
local function animate_detail(detail)
  if (not detail) then interrupt = interrupt - 1 end
  if interrupt > 0 and (not detail) then return end

  sbar.animate("tanh", 30, function()
    media_artist:set({ label = { width = detail and "dynamic" or 0 } })
    media_title:set({ label = { width = detail and "dynamic" or 0 } })
  end)
end

-- ── Album Art ─────────────────────────────────────────────────────
local function show_spotify_fallback()
  media_cover:set({
    icon = { drawing = true, string = icons.media.spotify, color = spotify_green },
    background = { image = { string = "" }, color = colors.bg2, drawing = true },
  })
  popup_art:set({
    icon = { drawing = true },
    background = { image = { string = "" }, color = colors.bg2 },
  })
end

local function download_and_set(url, cache_key, on_success)
  local filename = art_cache_dir .. "/" .. url:gsub("[^%w]", "_") .. ".jpg"
  sbar.exec("[ -f '" .. filename .. "' ] && echo 'exists' || curl -s --max-time 10 -o '" .. filename .. "' '" .. url .. "' && echo 'downloaded'", function(result)
    if type(result) ~= "string" then return end
    if result:match("exists") or result:match("downloaded") then
      on_success(filename)
    end
  end)
end

local function set_album_art(small_url, large_url)
  if (not small_url or small_url == "") and (not large_url or large_url == "") then
    show_spotify_fallback()
    return
  end

  -- Bar cover: use small image (300px) scaled to 28px
  local s_url = (small_url and small_url ~= "") and small_url or large_url
  if s_url ~= current_art_small then
    current_art_small = s_url
    download_and_set(s_url, "small", function(filename)
      -- Determine scale: image is ~300px, we want 28px
      media_cover:set({
        icon = { drawing = false },
        background = {
          image = { string = filename, scale = 0.09, corner_radius = 5 },
          color = colors.transparent,
          drawing = true,
        },
      })
    end)
  end

  -- Popup art: use large image (640px) scaled to 80px
  local l_url = (large_url and large_url ~= "") and large_url or s_url
  if l_url ~= current_art_large then
    current_art_large = l_url
    download_and_set(l_url, "large", function(filename)
      -- Determine scale: image is ~640px, we want 80px
      popup_art:set({
        icon = { drawing = false },
        background = {
          image = { string = filename, scale = 0.125, corner_radius = 8 },
          color = colors.transparent,
        },
      })
    end)
  end
end

local function show_last_played(track, artist, album, art_small, art_large)
  is_playing = false
  set_album_art(art_small, art_large)

  media_artist:set({ label = { string = artist, color = colors.with_alpha(colors.white, 0.35) } })
  media_title:set({ label = { string = track, color = colors.with_alpha(colors.white, 0.5) } })

  popup_track:set({ label = track })
  popup_artist:set({ label = artist })
  popup_album:set({ label = album })
  popup_controls:set({ icon = { string = controls_string(icons.media.play) } })
  media_cover:set({ icon = { color = colors.grey } })
end

local function build_recently_played_cmd(token)
  return "curl -s --max-time 10 -w '\\nHTTP_STATUS:%{http_code}'"
    .. " -H 'Authorization: Bearer " .. token .. "'"
    .. " 'https://api.spotify.com/v1/me/player/recently-played?limit=1'"
    .. " | " .. "python3" .. [[ -c "
import sys, json
raw = sys.stdin.read()
status_line = [l for l in raw.split('\n') if l.startswith('HTTP_STATUS:')]
http_status = int(status_line[0].split(':')[1]) if status_line else 0
if http_status == 401:
    print('UNAUTHORIZED')
    sys.exit(0)
if http_status != 200:
    print('IDLE')
    sys.exit(0)
body = '\n'.join(l for l in raw.split('\n') if not l.startswith('HTTP_STATUS:'))
try:
    d = json.loads(body)
    items = d.get('items', [])
    if not items:
        print('IDLE')
        sys.exit(0)
    item = items[0].get('track', {})
    album = item.get('album') or {}
    images = album.get('images') or []
    images.sort(key=lambda x: x.get('height', 0), reverse=True)
    art_large = ''
    art_small = ''
    for img in images:
        h = img.get('height', 0)
        url = img.get('url', '')
        if h >= 300 and not art_large:
            art_large = url
        if h >= 64 and h <= 300 and not art_small:
            art_small = url
    if not art_large and images:
        art_large = images[0].get('url', '')
    if not art_small:
        art_small = art_large
    artists = ', '.join(a.get('name', '') for a in (item.get('artists') or []))
    print(item.get('name', ''))
    print(artists)
    print(album.get('name', ''))
    print(art_small)
    print(art_large)
except Exception:
    print('IDLE')
"]]
end

local function fetch_recently_played()
  get_token(function(token)
    if not token then return end
    sbar.exec(build_recently_played_cmd(token), function(result)
      if type(result) ~= "string" then return end
      local trimmed = result:gsub("%s+$", "")
      if trimmed == "UNAUTHORIZED" then
        invalidate_token(function(new_token)
          if not new_token then return end
          sbar.exec(build_recently_played_cmd(new_token), function(retry_result)
            if type(retry_result) ~= "string" then return end
            local rt = retry_result:gsub("%s+$", "")
            if rt == "IDLE" or rt == "" or rt == "UNAUTHORIZED" then return end
            local lines = {}
            for line in retry_result:gmatch("[^\r\n]+") do
              table.insert(lines, line)
            end
            if #lines >= 3 then
              show_last_played(lines[1], lines[2], lines[3], lines[4] or "", lines[5] or "")
            end
          end)
        end)
        return
      end
      if trimmed == "IDLE" or trimmed == "" then return end
      local lines = {}
      for line in result:gmatch("[^\r\n]+") do
        table.insert(lines, line)
      end
      if #lines >= 3 then
        show_last_played(lines[1], lines[2], lines[3], lines[4] or "", lines[5] or "")
      end
    end)
  end)
end

local function show_idle()
  current_art_small = ""
  current_art_large = ""
  is_playing = false
  media_cover:set({
    icon = { drawing = true, color = colors.grey },
    background = { image = { string = "" }, color = colors.bg2, drawing = true },
  })
  media_artist:set({ label = "" })
  media_title:set({ label = "" })
  popup_art:set({
    icon = { drawing = true },
    background = { image = { string = "" }, color = colors.bg2 },
  })
  popup_track:set({ label = "Not Playing" })
  popup_artist:set({ label = "" })
  popup_album:set({ label = "" })
  popup_controls:set({ icon = { string = controls_string(icons.media.play) } })

  fetch_recently_played()
end

-- ── Playback Controls ─────────────────────────────────────────────
local function spotify_play_pause()
  if is_playing then
    spotify_api("PUT", "/v1/me/player/pause", nil)
    is_playing = false
    popup_controls:set({ icon = { string = controls_string(icons.media.play) } })
  else
    spotify_api("PUT", "/v1/me/player/play", nil)
    is_playing = true
    popup_controls:set({ icon = { string = controls_string(icons.media.pause) } })
  end
  sbar.delay(1, function() fetch_playback() end)
end

local function spotify_next()
  spotify_api("POST", "/v1/me/player/next", nil)
  sbar.delay(1, function() fetch_playback() end)
end

local function spotify_previous()
  spotify_api("POST", "/v1/me/player/previous", nil)
  sbar.delay(1, function() fetch_playback() end)
end

-- ── Fetch Playback State ──────────────────────────────────────────
local function build_playback_cmd(token)
  return "curl -s --max-time 10 -w '\\nHTTP_STATUS:%{http_code}'"
    .. " -H 'Authorization: Bearer " .. token .. "'"
    .. " 'https://api.spotify.com/v1/me/player'"
    .. " | " .. "python3" .. [[ -c "
import sys, json
raw = sys.stdin.read()
status_line = [l for l in raw.split('\n') if l.startswith('HTTP_STATUS:')]
http_status = int(status_line[0].split(':')[1]) if status_line else 0
if http_status == 401:
    print('UNAUTHORIZED')
    sys.exit(0)
if http_status == 204 or http_status == 0:
    print('IDLE')
    sys.exit(0)
body = '\n'.join(l for l in raw.split('\n') if not l.startswith('HTTP_STATUS:'))
try:
    d = json.loads(body)
    item = d.get('item') or {}
    album = item.get('album') or {}
    images = album.get('images') or []
    # Sort by height descending
    images.sort(key=lambda x: x.get('height', 0), reverse=True)
    art_large = ''
    art_small = ''
    for img in images:
        h = img.get('height', 0)
        url = img.get('url', '')
        if h >= 300 and not art_large:
            art_large = url
        if h >= 64 and h <= 300 and not art_small:
            art_small = url
    if not art_large and images:
        art_large = images[0].get('url', '')
    if not art_small:
        art_small = art_large
    artists = ', '.join(a.get('name', '') for a in (item.get('artists') or []))
    print(item.get('name', ''))
    print(artists)
    print(album.get('name', ''))
    print(art_small)
    print(art_large)
    print('true' if d.get('is_playing') else 'false')
except Exception:
    print('IDLE')
"]]
end

local function handle_playback_result(result)
  if type(result) ~= "string" then
    show_idle()
    return
  end

  local trimmed = result:gsub("%s+$", "")
  if trimmed == "UNAUTHORIZED" then return "UNAUTHORIZED" end
  if trimmed == "IDLE" or trimmed == "" then
    show_idle()
    return
  end

  local lines = {}
  for line in result:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  local track_name = lines[1] or ""
  local artist_name = lines[2] or ""
  local album_name = lines[3] or ""
  local art_small = lines[4] or ""
  local art_large = lines[5] or ""
  local playing = (lines[6] or "") == "true"

  if track_name == "" or track_name == "IDLE" then
    show_idle()
    return
  end

  is_playing = playing
  set_album_art(art_small, art_large)

  media_artist:set({ label = { string = artist_name, color = colors.with_alpha(colors.white, 0.6) } })
  media_title:set({ label = { string = track_name, color = colors.white } })

  popup_track:set({ label = track_name })
  popup_artist:set({ label = artist_name })
  popup_album:set({ label = album_name })
  popup_controls:set({
    icon = { string = controls_string(playing and icons.media.pause or icons.media.play) },
  })

  if playing then
    media_cover:set({ icon = { color = spotify_green } })
  end

  local track_id = artist_name .. " - " .. track_name
  if track_id ~= last_track and playing then
    animate_detail(true)
    interrupt = interrupt + 1
    sbar.delay(5, animate_detail)
    last_track = track_id
  elseif not playing and is_playing then
    last_track = ""
  end
end

local token_retry_count = 0
local MAX_TOKEN_RETRIES = 3

function fetch_playback()
  get_token(function(token)
    if not token then
      if token_retry_count < MAX_TOKEN_RETRIES then
        token_retry_count = token_retry_count + 1
        sbar.delay(5, function()
          invalidate_token(function() end)
          fetch_playback()
        end)
      else
        token_retry_count = 0
        show_idle()
      end
      return
    end
    token_retry_count = 0
    sbar.exec(build_playback_cmd(token), function(result)
      if handle_playback_result(result) == "UNAUTHORIZED" then
        invalidate_token(function(new_token)
          if not new_token then
            show_idle()
            return
          end
          sbar.exec(build_playback_cmd(new_token), function(retry_result)
            handle_playback_result(retry_result)
          end)
        end)
      end
    end)
  end)
end

-- ── Fetch Devices ─────────────────────────────────────────────────
local function build_devices_cmd(token)
  return "curl -s --max-time 10 -w '\\nHTTP_STATUS:%{http_code}'"
    .. " -H 'Authorization: Bearer " .. token .. "'"
    .. " 'https://api.spotify.com/v1/me/player/devices'"
    .. " | " .. "python3" .. [[ -c "
import sys, json
raw = sys.stdin.read()
status_line = [l for l in raw.split('\n') if l.startswith('HTTP_STATUS:')]
http_status = int(status_line[0].split(':')[1]) if status_line else 0
if http_status == 401:
    print('UNAUTHORIZED')
    sys.exit(0)
body = '\n'.join(l for l in raw.split('\n') if not l.startswith('HTTP_STATUS:'))
try:
    d = json.loads(body)
    for dev in d.get('devices', []):
        active = 'true' if dev.get('is_active') else 'false'
        print(dev.get('id', '') + '|' + dev.get('name', '') + '|' + active)
except:
    pass
"]]
end

local function handle_devices_result(result)
  if type(result) ~= "string" then return end
  local trimmed = result:gsub("%s+$", "")
  if trimmed == "UNAUTHORIZED" then return "UNAUTHORIZED" end
  local counter = 0
  for line in result:gmatch("[^\r\n]+") do
    local dev_id, dev_name, dev_active = line:match("^(.-)|(.-)|(.+)$")
    if dev_id and dev_name then
      local color = dev_active == "true" and spotify_green or colors.grey
      sbar.add("item", "media.device." .. counter, {
        position = "popup." .. media_cover.name,
        width = 200,
        label = { string = dev_name, color = color, width = 200, align = "center" },
        icon = { drawing = false },
        click_script = "curl -s -X PUT 'https://api.spotify.com/v1/me/player'"
          .. " -H 'Authorization: Bearer " .. (cached_token or "") .. "'"
          .. " -H 'Content-Type: application/json'"
          .. " -d '{\"device_ids\":[\"" .. dev_id .. "\"]}'"
          .. " && sketchybar --set /media.device\\\\.*/ label.color=" .. colors.grey
          .. " --set $NAME label.color=" .. spotify_green,
      })
      counter = counter + 1
    end
  end
end

local function fetch_devices()
  sbar.remove('/media.device\\.*/')

  get_token(function(token)
    if not token then return end
    sbar.exec(build_devices_cmd(token), function(result)
      if handle_devices_result(result) == "UNAUTHORIZED" then
        invalidate_token(function(new_token)
          if not new_token then return end
          sbar.exec(build_devices_cmd(new_token), function(retry_result)
            handle_devices_result(retry_result)
          end)
        end)
      end
    end)
  end)
end

-- ── Popup Toggle ──────────────────────────────────────────────────
local function toggle_popup()
  popup_is_open = not popup_is_open
  media_cover:set({ popup = { drawing = popup_is_open } })
  if popup_is_open then
    fetch_playback()
    fetch_devices()
  else
    sbar.remove('/media.device\\.*/')
  end
end

local function close_popup()
  if not popup_is_open then return end
  popup_is_open = false
  media_cover:set({ popup = { drawing = false } })
  sbar.remove('/media.device\\.*/')
end

-- ── Polling ───────────────────────────────────────────────────────
local poller = sbar.add("item", {
  drawing = false,
  update_freq = 10,
  updates = true,
})

local function on_wake()
  -- Invalidate token (including keychain cache) and art cache so everything refreshes cleanly
  current_art_small = ""
  current_art_large = ""
  -- Clear keychain cache then stagger retries (network may not be ready right after wake)
  invalidate_token(function()
    sbar.delay(3, function() fetch_playback() end)
    sbar.delay(8, function() fetch_playback() end)
  end)
end

poller:subscribe({ "routine", "forced" }, function()
  fetch_playback()
end)

poller:subscribe("system_woke", function()
  on_wake()
end)

-- ── Event Subscriptions ───────────────────────────────────────────
media_cover:subscribe("mouse.entered", function()
  interrupt = interrupt + 1
  animate_detail(true)
end)

media_cover:subscribe("mouse.exited", function()
  animate_detail(false)
end)

media_artist:subscribe("mouse.entered", function()
  interrupt = interrupt + 1
  animate_detail(true)
end)

media_artist:subscribe("mouse.exited", function()
  animate_detail(false)
end)

media_title:subscribe("mouse.entered", function()
  interrupt = interrupt + 1
  animate_detail(true)
end)

media_title:subscribe("mouse.exited", function()
  animate_detail(false)
end)

media_cover:subscribe("mouse.clicked", function()
  toggle_popup()
end)

popup_controls:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    spotify_next()
  else
    spotify_play_pause()
  end
end)

popup_controls:subscribe("mouse.scrolled", function(env)
  local delta = env.INFO.delta or 0
  if delta > 0 then
    spotify_next()
  elseif delta < 0 then
    spotify_previous()
  end
end)


media_cover:subscribe("mouse.exited.global", function()
  close_popup()
end)

"use strict";
(() => {
  // src/lib/resolvers.ts
  var DEBUG = false;
  function logResolved(name, method, el) {
    if (!DEBUG) return;
    console.debug(`[resolvers] ${name} via ${method}`, el);
  }
  function qs(selector, root = document) {
    return root.querySelector(selector);
  }
  function maintainInjection(opts) {
    let rafPending = false;
    const run = () => {
      const cur = opts.exists();
      if (cur && cur.isConnected) return;
      const parent = opts.target();
      if (!parent) return;
      opts.mount(parent);
    };
    run();
    const obs = new MutationObserver(() => {
      if (rafPending) return;
      rafPending = true;
      requestAnimationFrame(() => {
        rafPending = false;
        run();
      });
    });
    obs.observe(document.body, { childList: true, subtree: true });
    return () => obs.disconnect();
  }
  function getRightSidebar() {
    const byTestId = qs('[data-testid="right-sidebar"]');
    if (byTestId) {
      logResolved("getRightSidebar", "testid", byTestId);
      return byTestId;
    }
    const byClass = qs(".Root__right-sidebar");
    if (byClass) {
      logResolved("getRightSidebar", "class", byClass);
      return byClass;
    }
    return null;
  }

  // src/right-panel.ts
  (async function rightPanel() {
    while (!Spicetify?.Player?.addEventListener || !Spicetify?.Player?.data) {
      await new Promise((r) => setTimeout(r, 100));
    }
    const DEBUG_RECENT = false;
    const logR = (...args) => {
      if (!DEBUG_RECENT) return;
      console.log("[crp-recent]", ...args);
    };
    const FALLBACK_ICONS = {
      play: '<path d="M3 1.5v13l11-6.5z"/>',
      pause: '<path d="M2.7 1a.7.7 0 0 0-.7.7v12.6a.7.7 0 0 0 .7.7h2.6a.7.7 0 0 0 .7-.7V1.7a.7.7 0 0 0-.7-.7H2.7zm8 0a.7.7 0 0 0-.7.7v12.6a.7.7 0 0 0 .7.7h2.6a.7.7 0 0 0 .7-.7V1.7a.7.7 0 0 0-.7-.7h-2.6z"/>',
      "skip-back": '<path d="M3.3 1a.7.7 0 0 1 .7.7v5.4l8.4-5.6a1 1 0 0 1 1.6.8v11.4a1 1 0 0 1-1.6.8L4 8.9v5.4a.7.7 0 1 1-1.4 0V1.7a.7.7 0 0 1 .7-.7z"/>',
      "skip-forward": '<path d="M12.7 1a.7.7 0 0 0-.7.7v5.4L3.6 1.5A1 1 0 0 0 2 2.3v11.4a1 1 0 0 0 1.6.8L12 8.9v5.4a.7.7 0 1 0 1.4 0V1.7a.7.7 0 0 0-.7-.7z"/>',
      shuffle: '<path d="M13.1 2.3l2.6 2.3-2.6 2.3V5.5h-1.3c-.8 0-1.5.4-2 1L8.5 8 7.4 6.8l1.3-1.6c.7-.9 1.8-1.4 3-1.4h1.4V2.3zM2 3.7h1.9c1.2 0 2.3.5 3 1.4L13 12a2.4 2.4 0 0 0 2 1h1.3V14.7l-2.6 2.3-2.6-2.3V14h-1.3c-1.2 0-2.3-.5-3-1.4L3 5.1c-.3-.4-.7-.6-1.1-.6H2V3.7z"/>',
      repeat: '<path d="M0 4.75A3.75 3.75 0 0 1 3.75 1h8.5A3.75 3.75 0 0 1 16 4.75v5a3.75 3.75 0 0 1-3.75 3.75H9.81l1.018 1.018a.75.75 0 1 1-1.06 1.06L6.939 12.75l2.829-2.828a.75.75 0 1 1 1.06 1.06L9.811 12h2.439a2.25 2.25 0 0 0 2.25-2.25v-5a2.25 2.25 0 0 0-2.25-2.25h-8.5A2.25 2.25 0 0 0 1.5 4.75v5A2.25 2.25 0 0 0 3.75 12H5v1.5H3.75A3.75 3.75 0 0 1 0 9.75v-5z"/>',
      "repeat-once": '<path d="M0 4.75A3.75 3.75 0 0 1 3.75 1h8.5A3.75 3.75 0 0 1 16 4.75v5a3.75 3.75 0 0 1-3.75 3.75H9.81l1.018 1.018a.75.75 0 1 1-1.06 1.06L6.939 12.75l2.829-2.828a.75.75 0 1 1 1.06 1.06L9.811 12h2.439a2.25 2.25 0 0 0 2.25-2.25v-5a2.25 2.25 0 0 0-2.25-2.25h-8.5A2.25 2.25 0 0 0 1.5 4.75v5A2.25 2.25 0 0 0 3.75 12H5v1.5H3.75A3.75 3.75 0 0 1 0 9.75v-5z"/><path d="M8 7V5.5L6.5 6v.5L7 6.5V9H8V7z"/>',
      volume: '<path d="M9.741.85a.75.75 0 0 1 .375.65v13a.75.75 0 0 1-1.125.65L5.031 12H2.25A2.25 2.25 0 0 1 0 9.75v-3.5A2.25 2.25 0 0 1 2.25 4h2.781L8.99.2a.75.75 0 0 1 .75.65zm2.325 2.85a5 5 0 0 1 0 8.6l-.75-1.3a3.5 3.5 0 0 0 0-6l.75-1.3z"/>',
      "volume-off": '<path d="M9.741.85a.75.75 0 0 1 .375.65v13a.75.75 0 0 1-1.125.65L5.031 12H2.25A2.25 2.25 0 0 1 0 9.75v-3.5A2.25 2.25 0 0 1 2.25 4h2.781L8.99.2a.75.75 0 0 1 .75.65zM12 6.04l1.5 1.5 1.46-1.5L16 7.04l-1.5 1.5 1.5 1.46-1.04 1.04L13.5 9.54 12 11l-1.04-1.04 1.5-1.46-1.5-1.5L12 6.04z"/>',
      heart: '<path d="M1.69 2A4.58 4.58 0 0 1 8 2.023 4.58 4.58 0 0 1 11.88.817h.002a4.58 4.58 0 0 1 3.782 3.65v.003a4.82 4.82 0 0 1-1.63 4.521l-.023.02-6.003 5.553a.75.75 0 0 1-1.019.001L1.011 9.008l-.005-.005a4.82 4.82 0 0 1-.688-6.341A4.58 4.58 0 0 1 1.69 2zm3.356.418a3.08 3.08 0 0 0-3.668 2.155 3.32 3.32 0 0 0 .481 2.69L8 13.203l5.976-5.526a3.32 3.32 0 0 0 1.11-3.11 3.08 3.08 0 0 0-2.542-2.448 3.08 3.08 0 0 0-3.392 1.775.75.75 0 0 1-1.33.018 3.08 3.08 0 0 0-2.776-1.494z"/>',
      "heart-active": '<path d="M15.724 4.22A4.313 4.313 0 0 0 12.192.814a4.269 4.269 0 0 0-3.622 1.13.837.837 0 0 1-1.14 0 4.272 4.272 0 0 0-6.21 5.855l5.916 7.05a1.128 1.128 0 0 0 1.727 0l5.916-7.05a4.228 4.228 0 0 0 .945-3.577z"/>',
      x: '<path d="M2.47 2.47a.75.75 0 0 1 1.06 0L8 6.94l4.47-4.47a.75.75 0 1 1 1.06 1.06L9.06 8l4.47 4.47a.75.75 0 1 1-1.06 1.06L8 9.06l-4.47 4.47a.75.75 0 0 1-1.06-1.06L6.94 8 2.47 3.53a.75.75 0 0 1 0-1.06z"/>',
      "picture-in-picture": '<path d="M2 2h12a1 1 0 0 1 1 1v10a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V3a1 1 0 0 1 1-1zm.5 1.5v9h11v-9h-11zM8 7.5h5v4H8v-4z"/>',
      computer: '<path d="M1.5 2.75a.75.75 0 0 1 .75-.75h11.5a.75.75 0 0 1 .75.75v8.5a.75.75 0 0 1-.75.75H9v1.5h2.25a.75.75 0 0 1 0 1.5h-6.5a.75.75 0 0 1 0-1.5H7v-1.5H2.25a.75.75 0 0 1-.75-.75v-8.5zM3 3.5v7h10v-7H3z"/>',
      smartphone: '<path d="M4 1.5a1 1 0 0 1 1-1h6a1 1 0 0 1 1 1v13a1 1 0 0 1-1 1H5a1 1 0 0 1-1-1v-13zm1.5.5v11h5V2h-5zm2 12a.5.5 0 1 1 1 0 .5.5 0 0 1-1 0z"/>',
      speaker: '<path d="M3 1.5a1 1 0 0 1 1-1h8a1 1 0 0 1 1 1v13a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1v-13zm1.5.5v11h7V2h-7zM8 4a1 1 0 1 1 0 2 1 1 0 0 1 0-2zm0 4.5a2 2 0 1 1 0 4 2 2 0 0 1 0-4z"/>',
      device: '<path d="M1 4.75A.75.75 0 0 1 1.75 4h12.5a.75.75 0 0 1 .75.75v6.5a.75.75 0 0 1-.75.75H1.75a.75.75 0 0 1-.75-.75v-6.5zm1.5.75v5h11v-5h-11zM0 13.25a.75.75 0 0 1 .75-.75h14.5a.75.75 0 0 1 0 1.5H.75a.75.75 0 0 1-.75-.75z"/>'
    };
    function icon(name) {
      const inner = Spicetify.SVGIcons?.[name] ?? FALLBACK_ICONS[name] ?? "";
      return `<svg viewBox="0 0 16 16" fill="currentColor">${inner}</svg>`;
    }
    function fmtTime(ms) {
      if (!isFinite(ms) || ms < 0) ms = 0;
      const s = Math.floor(ms / 1e3);
      const m = Math.floor(s / 60);
      const ss = String(s % 60).padStart(2, "0");
      return `${m}:${ss}`;
    }
    function toHttpUrl(url) {
      if (!url) return null;
      if (url.startsWith("spotify:image:")) {
        return "https://i.scdn.co/image/" + url.slice("spotify:image:".length);
      }
      return url;
    }
    function escapeHtml(s) {
      const map = {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;"
      };
      return s.replace(/[&<>"']/g, (c) => map[c]);
    }
    let panelEl = null;
    let activeTab = "queue";
    let rafId = null;
    let seeking = false;
    function build() {
      const el = document.createElement("div");
      el.id = "custom-right-panel";
      el.innerHTML = `
      <div class="crp-player">
        <a class="crp-context" href="#"><span class="crp-context-label">Playing from</span> <span class="crp-context-name"></span></a>
        <div class="crp-cover-wrap"><div class="crp-cover"></div></div>
        <div class="crp-track-info">
          <div class="crp-track-text">
            <a class="crp-track-name crp-link"></a>
            <a class="crp-track-artist crp-link"></a>
            <a class="crp-track-album crp-link"></a>
          </div>
          <button class="crp-btn crp-miniplayer" title="Open miniplayer">${icon("picture-in-picture")}</button>
          <button class="crp-btn crp-like" title="Save to Liked Songs">${icon("heart")}</button>
        </div>
        <div class="crp-seek">
          <span class="crp-time-elapsed">0:00</span>
          <div class="crp-seek-bar"><div class="crp-seek-fill"></div><div class="crp-seek-thumb"></div></div>
          <span class="crp-time-total">0:00</span>
        </div>
        <div class="crp-controls">
          <button class="crp-btn crp-shuffle" title="Shuffle">${icon("shuffle")}</button>
          <button class="crp-btn crp-prev" title="Previous">${icon("skip-back")}</button>
          <button class="crp-btn crp-play-pause crp-primary" title="Play/Pause">${icon("play")}</button>
          <button class="crp-btn crp-next" title="Next">${icon("skip-forward")}</button>
          <button class="crp-btn crp-repeat" title="Repeat">${icon("repeat")}</button>
        </div>
        <div class="crp-volume">
          <button class="crp-btn crp-vol-icon" title="Mute">${icon("volume")}</button>
          <div class="crp-vol-bar"><div class="crp-vol-fill"></div><div class="crp-vol-thumb"></div></div>
          <span class="crp-vol-pct">100%</span>
        </div>
      </div>
      <div class="crp-tabs">
        <div class="crp-tab-bar" data-active="queue" data-user-queued="0">
          <button class="crp-tab active" data-tab="queue">Queue</button>
          <button class="crp-tab" data-tab="recent">Recent</button>
          <button class="crp-tab" data-tab="friends">Friends</button>
          <button class="crp-tab" data-tab="devices">Devices</button>
          <button class="crp-tab-action crp-clear-queue" title="Clear queue">${icon("x")}<span>Clear queue</span></button>
        </div>
        <div class="crp-tab-content">
          <div class="crp-tab-pane active" data-pane="queue"><div class="crp-list crp-queue-list"></div></div>
          <div class="crp-tab-pane" data-pane="recent"><div class="crp-list crp-recent-list"></div></div>
          <div class="crp-tab-pane" data-pane="friends"><div class="crp-list crp-friends-list"></div></div>
          <div class="crp-tab-pane" data-pane="devices"><div class="crp-list crp-devices-list"></div></div>
        </div>
      </div>
    `;
      wireControls(el);
      wireTabs(el);
      wireLinkNavigation(el);
      return el;
    }
    function wireLinkNavigation(root) {
      root.addEventListener(
        "click",
        (e) => {
          const link = e.target.closest(
            "a.crp-link"
          );
          if (!link) return;
          const href = link.getAttribute("href");
          if (!href || !href.startsWith("/")) return;
          e.preventDefault();
          e.stopPropagation();
          Spicetify.Platform.History.push(href);
        },
        true
      );
    }
    function wireControls(root) {
      root.querySelector(".crp-play-pause")?.addEventListener("click", () => Spicetify.Player.togglePlay());
      root.querySelector(".crp-prev")?.addEventListener("click", () => Spicetify.Player.back());
      root.querySelector(".crp-next")?.addEventListener("click", () => Spicetify.Player.next());
      root.querySelector(".crp-shuffle")?.addEventListener("click", () => {
        Spicetify.Player.toggleShuffle();
        syncShuffleRepeat();
      });
      root.querySelector(".crp-repeat")?.addEventListener("click", () => {
        const cur = Spicetify.Player.getRepeat();
        const next = (cur + 1) % 3;
        Spicetify.Player.setRepeat(next);
        syncShuffleRepeat();
      });
      root.querySelector(".crp-vol-icon")?.addEventListener("click", () => {
        Spicetify.Player.toggleMute();
        syncVolume();
      });
      root.querySelector(".crp-like")?.addEventListener("click", toggleLike);
      root.querySelector(".crp-miniplayer")?.addEventListener("click", () => {
        document.dispatchEvent(new CustomEvent("toggle-miniplayer"));
      });
      const seekBar = root.querySelector(".crp-seek-bar");
      if (seekBar) {
        const seekFromEvent = (e) => {
          const rect = seekBar.getBoundingClientRect();
          const frac = Math.max(
            0,
            Math.min(1, (e.clientX - rect.left) / rect.width)
          );
          const dur = Spicetify.Player.getDuration();
          return frac * dur;
        };
        seekBar.addEventListener("mousedown", (e) => {
          seeking = true;
          const ms = seekFromEvent(e);
          updateSeekUI(ms, Spicetify.Player.getDuration());
          const onMove = (ev) => {
            updateSeekUI(seekFromEvent(ev), Spicetify.Player.getDuration());
          };
          const onUp = (ev) => {
            document.removeEventListener("mousemove", onMove);
            document.removeEventListener("mouseup", onUp);
            Spicetify.Player.seek(Math.round(seekFromEvent(ev)));
            seeking = false;
          };
          document.addEventListener("mousemove", onMove);
          document.addEventListener("mouseup", onUp);
        });
      }
      const volBar = root.querySelector(".crp-vol-bar");
      if (volBar) {
        const volFromEvent = (e) => {
          const rect = volBar.getBoundingClientRect();
          return Math.max(0, Math.min(1, (e.clientX - rect.left) / rect.width));
        };
        volBar.addEventListener("mousedown", (e) => {
          const v = volFromEvent(e);
          Spicetify.Player.setVolume(v);
          updateVolumeUI(v);
          const onMove = (ev) => {
            const vv = volFromEvent(ev);
            Spicetify.Player.setVolume(vv);
            updateVolumeUI(vv);
          };
          const onUp = () => {
            document.removeEventListener("mousemove", onMove);
            document.removeEventListener("mouseup", onUp);
          };
          document.addEventListener("mousemove", onMove);
          document.addEventListener("mouseup", onUp);
        });
      }
    }
    function wireTabs(root) {
      root.querySelectorAll(".crp-tab").forEach((btn) => {
        btn.addEventListener("click", () => {
          const id = btn.dataset.tab;
          if (id) setActiveTab(id);
        });
      });
      root.querySelector(".crp-clear-queue")?.addEventListener("click", clearQueue);
    }
    const TAB_ORDER = {
      queue: 0,
      recent: 1,
      friends: 2,
      devices: 3
    };
    let lastTabIdx = 0;
    function setActiveTab(id) {
      if (!panelEl) return;
      const prevIdx = lastTabIdx;
      const newIdx = TAB_ORDER[id];
      activeTab = id;
      lastTabIdx = newIdx;
      panelEl.querySelectorAll(".crp-tab").forEach((el) => {
        el.classList.toggle("active", el.dataset.tab === id);
      });
      panelEl.querySelectorAll(".crp-tab-pane").forEach((el) => {
        el.classList.remove("crp-slide-right", "crp-slide-left");
        const isActive = el.dataset.pane === id;
        el.classList.toggle("active", isActive);
        if (isActive) {
          void el.offsetWidth;
          el.classList.add(newIdx >= prevIdx ? "crp-slide-right" : "crp-slide-left");
        }
      });
      const bar = panelEl.querySelector(".crp-tab-bar");
      if (bar) bar.dataset.active = id;
      if (id === "recent") renderRecentList();
      else if (id === "friends") refreshFriends();
      else if (id === "devices") refreshDevices();
    }
    function setLink(el, text, uri) {
      if (!el) return;
      el.textContent = text;
      if (uri) {
        const path = uri.replace(/^spotify:/, "/").replace(/:/g, "/");
        el.setAttribute("href", path);
      } else {
        el.removeAttribute("href");
      }
    }
    function syncTrackInfo() {
      if (!panelEl) return;
      const track = Spicetify.Player.data?.item;
      const meta = track?.metadata || {};
      const cover = toHttpUrl(meta.image_large_url || meta.image_url) || "";
      const name = meta.title || track?.name || "";
      const artist = meta.artist_name || "";
      const album = meta.album_title || "";
      const coverEl = panelEl.querySelector(".crp-cover");
      if (coverEl) coverEl.style.backgroundImage = cover ? `url('${cover}')` : "";
      setLink(
        panelEl.querySelector(".crp-track-name"),
        name,
        track?.uri
      );
      setLink(
        panelEl.querySelector(".crp-track-artist"),
        artist,
        meta.artist_uri
      );
      setLink(
        panelEl.querySelector(".crp-track-album"),
        album,
        meta.album_uri
      );
      syncContext();
    }
    function syncContext() {
      if (!panelEl) return;
      const data = Spicetify.Player.data;
      const meta = data?.item?.metadata;
      const name = data?.context?.metadata?.context_description || meta?.context_description || "";
      const uri = data?.context?.uri || meta?.context_uri || "";
      const link = panelEl.querySelector(".crp-context");
      const nameEl = panelEl.querySelector(".crp-context-name");
      if (!link || !nameEl) return;
      if (!name) {
        link.style.display = "none";
        return;
      }
      link.style.display = "";
      nameEl.textContent = name;
      if (uri) {
        const path = uri.replace(/^spotify:/, "/").replace(/:/g, "/");
        link.setAttribute("href", path);
        link.onclick = (e) => {
          e.preventDefault();
          Spicetify.Platform.History.push(path);
        };
      } else {
        link.removeAttribute("href");
        link.onclick = null;
      }
    }
    function syncPlayPause() {
      if (!panelEl) return;
      const btn = panelEl.querySelector(".crp-play-pause");
      if (!btn) return;
      const paused = Spicetify.Player.data?.isPaused ?? true;
      btn.innerHTML = icon(paused ? "play" : "pause");
    }
    function libraryApi() {
      return Spicetify.Platform?.LibraryAPI;
    }
    async function isLiked(uri) {
      const api = libraryApi();
      if (!api?.contains) return false;
      try {
        const res = await api.contains(uri);
        return Array.isArray(res) ? !!res[0] : !!res;
      } catch {
        return false;
      }
    }
    async function syncLikeState() {
      if (!panelEl) return;
      const btn = panelEl.querySelector(".crp-like");
      const uri = Spicetify.Player.data?.item?.uri;
      if (!btn) return;
      if (!uri || !uri.startsWith("spotify:track:")) {
        btn.classList.remove("active");
        btn.innerHTML = icon("heart");
        btn.setAttribute("title", "Save to Liked Songs");
        return;
      }
      const liked = await isLiked(uri);
      btn.classList.toggle("active", liked);
      btn.innerHTML = icon(liked ? "heart-active" : "heart");
      btn.setAttribute(
        "title",
        liked ? "Remove from Liked Songs" : "Save to Liked Songs"
      );
    }
    async function toggleLike() {
      const uri = Spicetify.Player.data?.item?.uri;
      if (!uri || !uri.startsWith("spotify:track:")) return;
      const api = libraryApi();
      if (!api) return;
      const liked = await isLiked(uri);
      try {
        if (liked) await api.remove?.({ uris: [uri] });
        else await api.add?.({ uris: [uri] });
      } catch {
      }
      await syncLikeState();
    }
    function readShuffle() {
      try {
        return !!Spicetify.Player.getShuffle();
      } catch {
        return !!Spicetify.Player.data?.shuffle;
      }
    }
    function readRepeat() {
      try {
        return Spicetify.Player.getRepeat();
      } catch {
        return Spicetify.Player.data?.repeat ?? 0;
      }
    }
    function syncShuffleRepeat() {
      if (!panelEl) return;
      const sh = panelEl.querySelector(".crp-shuffle");
      if (sh) sh.classList.toggle("active", readShuffle());
      const rp = panelEl.querySelector(".crp-repeat");
      if (rp) {
        const mode = readRepeat();
        rp.classList.toggle("active", mode !== 0);
        rp.innerHTML = icon(mode === 2 ? "repeat-once" : "repeat");
      }
    }
    function syncVolume() {
      if (!panelEl) return;
      const v = Spicetify.Player.getVolume();
      updateVolumeUI(v);
      const ic = panelEl.querySelector(".crp-vol-icon");
      if (ic) {
        const muted = (() => {
          try {
            return Spicetify.Player.getMute();
          } catch {
            return false;
          }
        })();
        ic.innerHTML = icon(muted || v === 0 ? "volume-off" : "volume");
      }
    }
    function updateVolumeUI(v) {
      if (!panelEl) return;
      const fill = panelEl.querySelector(".crp-vol-fill");
      const thumb = panelEl.querySelector(".crp-vol-thumb");
      const pct = panelEl.querySelector(".crp-vol-pct");
      const pctStr = `${Math.round(v * 100)}%`;
      if (fill) fill.style.width = pctStr;
      if (thumb) thumb.style.left = pctStr;
      if (pct) pct.textContent = pctStr;
    }
    function updateSeekUI(progressMs, durationMs) {
      if (!panelEl) return;
      const fill = panelEl.querySelector(".crp-seek-fill");
      const thumb = panelEl.querySelector(".crp-seek-thumb");
      const el = panelEl.querySelector(".crp-time-elapsed");
      const tot = panelEl.querySelector(".crp-time-total");
      const pct = durationMs > 0 ? Math.max(0, Math.min(1, progressMs / durationMs)) : 0;
      if (fill) fill.style.width = `${pct * 100}%`;
      if (thumb) thumb.style.left = `${pct * 100}%`;
      if (el) el.textContent = fmtTime(progressMs);
      if (tot) tot.textContent = fmtTime(durationMs);
    }
    function getAccurateProgress() {
      const data = Spicetify.Player.data;
      if (data?.position_as_of_timestamp != null && data.timestamp != null) {
        return data.isPaused ? data.position_as_of_timestamp : data.position_as_of_timestamp + (Date.now() - data.timestamp);
      }
      return Spicetify.Player.getProgress();
    }
    function startProgressLoop() {
      if (rafId != null) cancelAnimationFrame(rafId);
      const tick = () => {
        if (!seeking) {
          const dur = Spicetify.Player.getDuration();
          updateSeekUI(getAccurateProgress(), dur);
        }
        rafId = requestAnimationFrame(tick);
      };
      rafId = requestAnimationFrame(tick);
    }
    function linkHtml(uri, text, extraClass = "") {
      const safe = escapeHtml(text);
      const cls = ["crp-link", extraClass].filter(Boolean).join(" ");
      if (!uri) return `<span class="${extraClass}">${safe}</span>`;
      const path = uri.replace(/^spotify:/, "/").replace(/:/g, "/");
      return `<a class="${cls}" href="${path}">${safe}</a>`;
    }
    function normalizeQueueItem(item) {
      const any = item;
      const src = any.contextTrack || any.track || any;
      const uri = src.uri || any.uri || "";
      if (!uri || !uri.startsWith("spotify:track:")) return null;
      const uid = any.uid || src.uid || "";
      const meta = src.metadata || any.metadata || {};
      return {
        uri,
        uid,
        name: meta.title || meta.track_title || src.name || uri,
        artist: meta.artist_name || "",
        artistUri: meta.artist_uri || "",
        album: meta.album_title || "",
        albumUri: meta.album_uri || "",
        art: toHttpUrl(meta.image_small_url || meta.image_url) || ""
      };
    }
    let userQueuedCount = 0;
    async function fetchQueue() {
      const platform = Spicetify.Platform;
      const api = platform?.PlayerAPI;
      let raw = [];
      let queued = 0;
      if (api?.getQueue) {
        try {
          const s = await api.getQueue();
          const userQ = Array.isArray(s?.queued) ? s.queued : [];
          const nextUp = Array.isArray(s?.nextUp) ? s.nextUp : [];
          queued = userQ.length;
          if (userQ.length || nextUp.length) {
            raw = userQ.concat(nextUp);
          } else if (Array.isArray(s?.nextTracks)) {
            raw = s.nextTracks;
          } else if (Array.isArray(s?.queue?.nextTracks)) {
            raw = s.queue.nextTracks;
          }
        } catch {
        }
      }
      if (raw.length === 0) {
        const g = Spicetify.Queue;
        const fallback = g?.nextTracks || g?._queue?.nextTracks || [];
        if (Array.isArray(fallback)) raw = fallback;
      }
      userQueuedCount = queued;
      const out = [];
      for (const item of raw) {
        const n = normalizeQueueItem(item);
        if (n) out.push(n);
      }
      return out;
    }
    let cachedQueue = [];
    function renderQueueRow(t, i) {
      const artist = t.artist ? linkHtml(t.artistUri, t.artist) : "";
      const album = t.album ? linkHtml(t.albumUri, t.album) : "";
      const sub = [artist, album].filter(Boolean).join(" \xB7 ");
      return `
      <div class="crp-list-row crp-queue-row" data-idx="${i}" draggable="true">
        <div class="crp-drag-handle" aria-hidden="true">&#x2261;</div>
        <div class="crp-list-art" style="background-image: url('${t.art}');"></div>
        <div class="crp-list-info">
          ${linkHtml(t.uri, t.name, "crp-list-name")}
          <span class="crp-list-sub">${sub}</span>
        </div>
        <div class="crp-row-actions">
          <button class="crp-row-btn" data-action="remove" title="Remove from queue">&times;</button>
        </div>
      </div>`;
    }
    function renderQueue(list) {
      if (!panelEl) return;
      const container = panelEl.querySelector(".crp-queue-list");
      if (!container) return;
      if (list.length === 0) {
        container.innerHTML = '<div class="crp-empty">Queue is empty</div>';
        return;
      }
      const split = Math.min(userQueuedCount, list.length);
      const user = list.slice(0, split).map((t, i) => renderQueueRow(t, i));
      const auto = list.slice(split).map((t, i) => renderQueueRow(t, split + i));
      const divider = user.length > 0 && auto.length > 0 ? '<div class="crp-queue-divider">Next up</div>' : "";
      container.innerHTML = user.join("") + divider + auto.join("");
    }
    function clearDropIndicators(container) {
      container.querySelectorAll(
        ".crp-drop-before, .crp-drop-after"
      ).forEach((el) => {
        el.classList.remove("crp-drop-before", "crp-drop-after");
      });
    }
    function wireQueueDelegation(container) {
      const rowOf = (e) => e.target.closest(".crp-queue-row");
      container.addEventListener("click", (e) => {
        const row = rowOf(e);
        if (!row) return;
        const target = e.target;
        const btn = target.closest(".crp-row-btn");
        if (btn) {
          e.stopPropagation();
          const idx2 = parseInt(row.dataset.idx ?? "-1", 10);
          if (btn.dataset.action === "remove") removeFromQueue(idx2);
          return;
        }
        if (target.closest(".crp-drag-handle")) return;
        if (target.closest("a.crp-link")) return;
        const idx = parseInt(row.dataset.idx ?? "-1", 10);
        if (idx >= 0) void skipToQueueItem(idx);
      });
      container.addEventListener("dragstart", (e) => {
        const row = rowOf(e);
        if (!row) return;
        const idx = parseInt(row.dataset.idx ?? "-1", 10);
        if (idx < 0) return;
        e.dataTransfer?.setData("text/plain", String(idx));
        const dt = e.dataTransfer;
        if (dt) dt.effectAllowed = "move";
        row.classList.add("crp-dragging");
      });
      container.addEventListener("dragend", (e) => {
        const row = rowOf(e);
        if (row) row.classList.remove("crp-dragging");
        clearDropIndicators(container);
      });
      container.addEventListener("dragover", (e) => {
        const row = rowOf(e);
        if (!row) return;
        e.preventDefault();
        const dt = e.dataTransfer;
        if (dt) dt.dropEffect = "move";
        const rect = row.getBoundingClientRect();
        const before = e.clientY < rect.top + rect.height / 2;
        if (!row.classList.contains(before ? "crp-drop-before" : "crp-drop-after")) {
          clearDropIndicators(container);
          row.classList.toggle("crp-drop-before", before);
          row.classList.toggle("crp-drop-after", !before);
        }
      });
      container.addEventListener("contextmenu", (e) => {
        const row = rowOf(e);
        if (!row) return;
        e.preventDefault();
        const idx = parseInt(row.dataset.idx ?? "-1", 10);
        const t = cachedQueue[idx];
        if (!t) return;
        menuForRowEvent(e, {
          uri: t.uri,
          artistUri: t.artistUri,
          albumUri: t.albumUri,
          queueIdx: idx
        }).then((items) => showContextMenu(items, e.clientX, e.clientY));
      });
      container.addEventListener("drop", (e) => {
        const row = rowOf(e);
        if (!row) return;
        e.preventDefault();
        const fromIdx = parseInt(
          e.dataTransfer?.getData("text/plain") ?? "-1",
          10
        );
        const targetIdx = parseInt(row.dataset.idx ?? "-1", 10);
        const dropBefore = row.classList.contains("crp-drop-before");
        clearDropIndicators(container);
        if (fromIdx < 0 || targetIdx < 0 || fromIdx === targetIdx) return;
        const insertIdx = dropBefore ? targetIdx : targetIdx + 1;
        if (insertIdx === fromIdx || insertIdx === fromIdx + 1) return;
        const source = cachedQueue[fromIdx];
        if (!source) return;
        const beforeItem = cachedQueue[insertIdx] ?? null;
        moveToPosition(source, beforeItem);
      });
    }
    function playerApi() {
      return Spicetify.Platform?.PlayerAPI;
    }
    async function clearQueue() {
      const api = playerApi();
      if (!api) return;
      try {
        if (api.clearQueue) {
          await api.clearQueue();
        } else if (api.removeFromQueue && cachedQueue.length > 0) {
          await api.removeFromQueue(
            cachedQueue.map((t) => ({ uri: t.uri, uid: t.uid }))
          );
        }
        await refreshQueue(true);
      } catch {
      }
    }
    async function skipToQueueItem(idx) {
      const item = cachedQueue[idx];
      if (!item) return;
      const api = playerApi();
      if (!api) {
        Spicetify.Player.playUri(item.uri);
        return;
      }
      const itemRef = {
        uri: item.uri,
        uid: item.uid,
        provider: idx < userQueuedCount ? "queue" : "context"
      };
      for (const fn of [api.skipToNextTrack, api.skipNext, api.skipToNext]) {
        if (typeof fn !== "function") continue;
        try {
          await fn.call(api, itemRef);
          return;
        } catch {
        }
      }
      if (typeof api.skipToIndex === "function") {
        try {
          await api.skipToIndex(idx);
          return;
        } catch {
        }
      }
      Spicetify.Player.playUri(item.uri);
    }
    async function removeFromQueue(idx) {
      const item = cachedQueue[idx];
      const api = playerApi();
      if (!item || !api?.removeFromQueue) return;
      try {
        await api.removeFromQueue([{ uri: item.uri, uid: item.uid }]);
        await refreshQueue(true);
      } catch {
      }
    }
    async function moveToPosition(source, before) {
      const api = playerApi();
      if (!api?.reorderQueue) return;
      const srcTrack = { uri: source.uri, uid: source.uid };
      try {
        if (before) {
          await api.reorderQueue([srcTrack], {
            before: { uri: before.uri, uid: before.uid }
          });
        } else {
          const last = cachedQueue[cachedQueue.length - 1];
          if (!last || last.uid === source.uid) return;
          await api.reorderQueue([srcTrack], {
            after: { uri: last.uri, uid: last.uid }
          });
        }
        await refreshQueue(true);
      } catch {
      }
    }
    let lastQueueKey = "";
    async function refreshQueue(force = false) {
      const list = await fetchQueue();
      const key = list.map((t) => t.uid || t.uri).join("|");
      if (panelEl) {
        const bar = panelEl.querySelector(".crp-tab-bar");
        if (bar) bar.dataset.userQueued = String(userQueuedCount);
      }
      if (!force && key === lastQueueKey) return;
      lastQueueKey = key;
      cachedQueue = list;
      renderQueue(list);
    }
    function parseTimestamp(v) {
      if (typeof v === "number" && isFinite(v)) {
        return v < 1e12 ? v * 1e3 : v;
      }
      if (typeof v === "string") {
        const n = Date.parse(v);
        if (!isNaN(n)) return n;
      }
      return 0;
    }
    function relTime(ms) {
      if (!ms) return "";
      const diff = Date.now() - ms;
      if (diff < 0) return "just now";
      const mins = Math.floor(diff / 6e4);
      if (mins < 1) return "just now";
      if (mins < 60) return `${mins}m ago`;
      const hours = Math.floor(mins / 60);
      if (hours < 24) return `${hours}h ago`;
      const days = Math.floor(hours / 24);
      if (days < 2) return "yesterday";
      if (days < 7) return `${days}d ago`;
      const weeks = Math.floor(days / 7);
      if (weeks < 5) return `${weeks}w ago`;
      const months = Math.floor(days / 30);
      if (months < 12) return `${months}mo ago`;
      return `${Math.floor(days / 365)}y ago`;
    }
    function extractArtUrl(sources) {
      if (!Array.isArray(sources)) return "";
      for (const s of sources) {
        const url = s?.url;
        if (url) return url;
      }
      return "";
    }
    function normalizeRecentItem(raw) {
      const any = raw;
      const t = any.item || any.track || any;
      const uri = t?.uri || any.uri || "";
      if (!uri || !uri.startsWith("spotify:track:")) return null;
      const name = t?.name || (t?.metadata?.title ?? "") || uri;
      let artist = "";
      let artistUri = "";
      const artistLike = t?.contributors ?? t?.artists;
      if (Array.isArray(artistLike) && artistLike.length > 0) {
        artist = artistLike.map((a) => a?.name ?? a?.profile?.name ?? "").filter(Boolean).join(", ");
        artistUri = artistLike[0]?.uri ?? "";
      }
      if (!artist) {
        const meta = t?.metadata;
        artist = meta?.artist_name ?? "";
        artistUri = meta?.artist_uri ?? "";
      }
      const album = "";
      const albumUri = "";
      const coverSources = t?.album?.images || t?.album?.coverArt?.sources || t?.albumOfTrack?.coverArt?.sources || t?.images;
      let art = extractArtUrl(coverSources);
      if (!art) {
        const meta = t?.metadata;
        art = meta?.image_small_url || meta?.image_url || "";
      }
      const ts = any?.addedAt;
      const tsCandidates = [
        ts?.timestamp,
        any?.playedAt,
        any?.played_at,
        any?.addedAt,
        any?.added_at,
        any?.lastPlayedAt,
        any?.timestamp,
        t?.playedAt,
        t?.played_at,
        t?.lastPlayedAt,
        t?.timestamp
      ];
      let playedAt = 0;
      for (const c of tsCandidates) {
        const n = parseTimestamp(c);
        if (n) {
          playedAt = n;
          break;
        }
      }
      return {
        uri,
        name,
        artist,
        artistUri,
        album,
        albumUri,
        art: toHttpUrl(art) || "",
        playedAt
      };
    }
    async function tryOne(fn) {
      const res = await fn();
      if (res == null) return null;
      const hasAnyArray = Object.values(res).some(Array.isArray);
      const isSubscription = !Array.isArray(res) && (res._emitter || typeof res.cancel === "function");
      if (!hasAnyArray && isSubscription) return null;
      return res;
    }
    async function probeAttempts(attempts) {
      for (const [label, fn] of attempts) {
        try {
          const res = await tryOne(fn);
          if (res == null) continue;
          return { hit: label, fn, raw: res };
        } catch {
        }
      }
      return null;
    }
    function apiOf(name) {
      return Spicetify.Platform[name];
    }
    let friendsWinner = null;
    async function fetchRecentsRaw() {
      const api = apiOf("RecentsAPI");
      const fn = api?.getContents;
      if (typeof fn !== "function") {
        logR("fetchRecentsRaw: RecentsAPI.getContents unavailable");
        return [];
      }
      try {
        const res = await fn.call(api);
        const arr = pickArray(res);
        if (!arr) {
          logR("fetchRecentsRaw: pickArray empty", res);
          return [];
        }
        return arr;
      } catch (err) {
        logR("fetchRecentsRaw error", err);
        return [];
      }
    }
    function normalizeWindow(raw, start, wanted) {
      const items = [];
      let i = start;
      while (i < raw.length && items.length < wanted) {
        const n = normalizeRecentItem(raw[i]);
        if (n) items.push(n);
        i++;
      }
      return { items, consumed: i - start };
    }
    function bustRecentsCache() {
      try {
        const api = apiOf("RecentsAPI");
        const c = api?._cache;
        if (!c) return;
        if (typeof c.clear === "function") {
          c.clear();
          logR("bustRecentsCache: cleared via .clear()");
        } else if (c._cache) {
          c._cache = {};
          logR("bustRecentsCache: cleared via _cache._cache = {}");
        }
      } catch (err) {
        logR("bustRecentsCache threw", err);
      }
    }
    function pickArray(res) {
      if (Array.isArray(res)) return res;
      if (!res || typeof res !== "object") return null;
      const o = res;
      const candidateKeys = [
        "items",
        "contents",
        "events",
        "tracks",
        "recents",
        "friends",
        "buddies",
        "activities"
      ];
      for (const k of candidateKeys) {
        const v = o[k];
        if (Array.isArray(v)) return v;
        if (v && typeof v === "object") {
          const inner = pickArray(v);
          if (inner && inner.length > 0) return inner;
        }
      }
      for (const wrap of ["data", "state", "result", "body", "payload"]) {
        const w = o[wrap];
        if (w && typeof w === "object") {
          const inner = pickArray(w);
          if (inner) return inner;
        }
      }
      return null;
    }
    function renderSimpleList(container, items, emptyMsg) {
      if (items.length === 0) {
        container.innerHTML = `<div class="crp-empty">${escapeHtml(emptyMsg)}</div>`;
        return;
      }
      container.innerHTML = items.map((t, i) => {
        const artist = t.artist ? linkHtml(t.artistUri, t.artist) : "";
        const album = t.album ? linkHtml(t.albumUri, t.album) : "";
        const extra = t.subExtra ? escapeHtml(t.subExtra) : "";
        const sub = [artist, album, extra].filter(Boolean).join(" \xB7 ");
        const aAttr = t.artistUri ? ` data-artist-uri="${escapeHtml(t.artistUri)}"` : "";
        const alAttr = t.albumUri ? ` data-album-uri="${escapeHtml(t.albumUri)}"` : "";
        return `
        <div class="crp-list-row" data-idx="${i}" data-uri="${escapeHtml(t.uri)}"${aAttr}${alAttr}>
          <div class="crp-list-art" style="background-image: url('${t.art}');"></div>
          <div class="crp-list-info">
            ${linkHtml(t.uri, t.name, "crp-list-name")}
            <span class="crp-list-sub">${sub}</span>
          </div>
        </div>
      `;
      }).join("");
    }
    function wireSimpleListDelegation(container) {
      container.addEventListener("click", (e) => {
        const target = e.target;
        if (target.closest("a.crp-link")) return;
        const row = target.closest(".crp-list-row");
        const uri = row?.dataset.uri;
        if (uri) Spicetify.Player.playUri(uri);
      });
      container.addEventListener("contextmenu", (e) => {
        const row = e.target.closest(".crp-list-row");
        const uri = row?.dataset.uri;
        if (!row || !uri) return;
        e.preventDefault();
        menuForRowEvent(e, {
          uri,
          artistUri: row.dataset.artistUri,
          albumUri: row.dataset.albumUri
        }).then((items) => showContextMenu(items, e.clientX, e.clientY));
      });
    }
    const RECENT_PAGE_SIZE = 30;
    let recentItems = [];
    let recentRawConsumed = 0;
    let recentExhausted = false;
    let recentLoading = false;
    async function refreshRecent(reset = false) {
      logR("refreshRecent called, reset =", reset, "; panelEl?", !!panelEl);
      if (!panelEl) return;
      if (reset) {
        bustRecentsCache();
        recentExhausted = false;
        recentRawConsumed = 0;
      }
      const raw = await fetchRecentsRaw();
      if (!panelEl) return;
      const wanted = reset || recentItems.length === 0 ? RECENT_PAGE_SIZE : recentItems.length;
      const { items: fresh, consumed } = normalizeWindow(raw, 0, wanted);
      const prevFirst = recentItems[0]?.uri;
      recentItems = fresh;
      recentRawConsumed = consumed;
      recentExhausted = consumed >= raw.length;
      logR(
        `refreshRecent: raw=${raw.length}, consumed=${consumed}, items=${fresh.length}, exhausted=${recentExhausted}; first ${prevFirst} \u2192 ${recentItems[0]?.uri} (changed? ${prevFirst !== recentItems[0]?.uri})`
      );
      renderRecentList();
    }
    function renderRecentList() {
      if (!panelEl) return;
      const container = panelEl.querySelector(".crp-recent-list");
      if (!container) return;
      const pane = container.closest(".crp-tab-pane");
      const prevScroll = pane?.scrollTop ?? 0;
      const rows = recentItems.map((t) => ({
        ...t,
        subExtra: relTime(t.playedAt)
      }));
      renderSimpleList(container, rows, "No recent tracks");
      if (pane) pane.scrollTop = prevScroll;
      logR(
        "renderRecentList: rendered",
        rows.length,
        "items; exhausted?",
        recentExhausted
      );
    }
    async function loadMoreRecent() {
      if (recentLoading || recentExhausted || !panelEl) return;
      recentLoading = true;
      try {
        const raw = await fetchRecentsRaw();
        if (!panelEl) return;
        const { items: more, consumed } = normalizeWindow(
          raw,
          recentRawConsumed,
          RECENT_PAGE_SIZE
        );
        recentRawConsumed += consumed;
        recentItems = [...recentItems, ...more];
        recentExhausted = recentRawConsumed >= raw.length;
        logR(
          `loadMoreRecent: raw=${raw.length}, consumed=${recentRawConsumed}, now displaying=${recentItems.length}, exhausted=${recentExhausted}`
        );
        renderRecentList();
      } finally {
        recentLoading = false;
      }
    }
    function wireRecentInfiniteScroll(pane) {
      logR(
        "wireRecentInfiniteScroll: attached to pane",
        pane,
        "; initial scrollHeight =",
        pane.scrollHeight,
        "clientHeight =",
        pane.clientHeight
      );
      let rafPending = false;
      let logCounter = 0;
      pane.addEventListener(
        "scroll",
        () => {
          if (rafPending) return;
          rafPending = true;
          requestAnimationFrame(() => {
            rafPending = false;
            const { scrollTop, scrollHeight, clientHeight } = pane;
            if (++logCounter % 10 === 0) {
              logR(
                `scroll tick: top=${Math.round(scrollTop)}, client=${clientHeight}, height=${scrollHeight}, loading=${recentLoading}, exhausted=${recentExhausted}`
              );
            }
            if (recentLoading || recentExhausted) return;
            if (scrollTop + clientHeight >= scrollHeight - 400) {
              logR("scroll: near bottom, triggering loadMoreRecent");
              void loadMoreRecent();
            }
          });
        },
        { passive: true }
      );
    }
    function timeAgo(ms) {
      if (!ms) return "";
      const diff = Date.now() - ms;
      const mins = Math.floor(diff / 6e4);
      if (mins < 1) return "just now";
      if (mins < 60) return `${mins}m ago`;
      const hours = Math.floor(mins / 60);
      if (hours < 24) return `${hours}h ago`;
      const days = Math.floor(hours / 24);
      return `${days}d ago`;
    }
    const FRIENDS_METHODS = [
      "getBuddyFeed",
      "getBuddies",
      "getFriends",
      "getFriendActivity",
      "getItems",
      "getState",
      "fetch"
    ];
    async function fetchFriends() {
      const apiNames = ["BuddyFeedAPI", "SocialConnectAPI"];
      const buddy = apiOf("BuddyFeedAPI");
      const attempts = [];
      for (const prop of ["presenceView", "presence2", "batchAPI"]) {
        const obj = buddy?.[prop];
        if (!obj) continue;
        for (const m of [
          "getBuddyFeed",
          "getFriendActivity",
          "getState",
          "getData",
          "getItems",
          "getCurrentState",
          "fetch",
          "read"
        ]) {
          if (typeof obj[m] === "function") {
            attempts.push([
              `BuddyFeedAPI.${prop}.${m}()`,
              () => obj[m]?.()
            ]);
          }
        }
      }
      for (const n of apiNames) {
        const a = apiOf(n);
        if (!a) continue;
        for (const m of FRIENDS_METHODS) {
          if (typeof a[m] === "function") {
            attempts.push([`${n}.${m}()`, () => a[m]?.()]);
          }
        }
      }
      let rawRes = null;
      if (friendsWinner) {
        try {
          rawRes = await tryOne(friendsWinner.fn);
        } catch {
          friendsWinner = null;
        }
      }
      if (rawRes == null) {
        const hit = await probeAttempts(attempts);
        if (!hit) return [];
        friendsWinner = { label: hit.hit, fn: hit.fn };
        rawRes = hit.raw;
      }
      const raw = pickArray(rawRes);
      if (!raw || raw.length === 0) return [];
      const out = [];
      for (const entry of raw) {
        const f = entry;
        const user = f?.user || {};
        const track = f?.track || {};
        const album = track?.album || {};
        const context = f?.context || track?.context || {};
        const timestamp = f?.timestamp ?? 0;
        const artistObj = track?.artist;
        const artistsArr = track?.artists;
        const artistName = artistObj?.name || (artistsArr?.map((a) => a?.name ?? "").filter(Boolean).join(", ") ?? "");
        const artistUri = artistObj?.uri || artistsArr?.[0]?.uri || "";
        out.push({
          userName: user?.name || user?.displayName || "Unknown",
          userUri: user?.uri || "",
          avatarUrl: toHttpUrl(user?.imageUrl || "") || "",
          trackUri: track?.uri || "",
          trackName: track?.name || "",
          artist: artistName,
          artistUri,
          album: album?.name || "",
          albumUri: album?.uri || "",
          context: context?.name || album?.name || "",
          contextUri: context?.uri || album?.uri || "",
          timestamp,
          isPlaying: timestamp === 0 || Date.now() - timestamp < 3e4
        });
      }
      out.reverse();
      return out;
    }
    function renderFriends(list) {
      if (!panelEl) return;
      const container = panelEl.querySelector(".crp-friends-list");
      if (!container) return;
      if (list.length === 0) {
        container.innerHTML = '<div class="crp-empty">No friend activity</div>';
        return;
      }
      container.innerHTML = list.map((f, i) => {
        const track = linkHtml(f.trackUri, f.trackName);
        const artist = f.artist ? linkHtml(f.artistUri, f.artist) : "";
        const context = f.context ? linkHtml(f.contextUri, f.context) : "";
        const userName = linkHtml(f.userUri, f.userName, "crp-friend-name");
        const trackLine = [track, artist].filter(Boolean).join(" \xB7 ");
        const meta = f.isPlaying ? "listening now" : escapeHtml(timeAgo(f.timestamp));
        const contextLine = context ? `${meta} \xB7 ${context}` : meta;
        const aAttr = f.artistUri ? ` data-artist-uri="${escapeHtml(f.artistUri)}"` : "";
        const alAttr = f.albumUri ? ` data-album-uri="${escapeHtml(f.albumUri)}"` : "";
        return `
        <div class="crp-friend-row" data-idx="${i}" data-uri="${escapeHtml(f.trackUri)}"${aAttr}${alAttr}>
          <div class="crp-friend-avatar"${f.avatarUrl ? ` style="background-image: url('${f.avatarUrl}');"` : ""}>
            ${f.isPlaying ? '<span class="crp-friend-dot"></span>' : ""}
          </div>
          <div class="crp-friend-info">
            ${userName}
            <div class="crp-friend-track">${trackLine}</div>
            <div class="crp-friend-context">${contextLine}</div>
          </div>
        </div>
      `;
      }).join("");
    }
    function wireFriendsDelegation(container) {
      container.addEventListener("click", (e) => {
        const target = e.target;
        if (target.closest("a.crp-link")) return;
        const row = target.closest(".crp-friend-row");
        const uri = row?.dataset.uri;
        if (uri) Spicetify.Player.playUri(uri);
      });
      container.addEventListener("contextmenu", (e) => {
        const row = e.target.closest(".crp-friend-row");
        const uri = row?.dataset.uri;
        if (!row || !uri) return;
        e.preventDefault();
        menuForRowEvent(e, {
          uri,
          artistUri: row.dataset.artistUri,
          albumUri: row.dataset.albumUri
        }).then((items) => showContextMenu(items, e.clientX, e.clientY));
      });
    }
    let lastFriendsKey = "";
    async function refreshFriends(force = false) {
      const list = await fetchFriends();
      const key = list.map((f) => `${f.userUri}:${f.trackUri}:${f.timestamp}`).join("|");
      if (!force && key === lastFriendsKey) return;
      lastFriendsKey = key;
      renderFriends(list);
    }
    function normalizeDevice(raw) {
      if (!raw || typeof raw !== "object") return null;
      const d = raw;
      const id = d.identifier || d.id || "";
      const name = d.name || "";
      if (!id || !name) return null;
      const rawType = (d.type || d.deviceType || d.category || "device").toString().toLowerCase();
      let type;
      if (/phone|mobile/.test(rawType)) type = "smartphone";
      else if (/computer|laptop|desktop/.test(rawType)) type = "computer";
      else if (/speaker|audio|av|stereo|sonos|chromecast|cast/.test(rawType))
        type = "speaker";
      else type = "device";
      return {
        id,
        name,
        type,
        isActive: !!(d.isActive ?? d.is_active),
        isLocal: !!(d.isLocalDevice ?? d.isLocal ?? d.is_local)
      };
    }
    function pickDeviceArray(res) {
      if (!res) return null;
      if (Array.isArray(res)) return res;
      const r = res;
      if (Array.isArray(r.devices)) return r.devices;
      if (Array.isArray(r.availableDevices)) return r.availableDevices;
      const state = r.state;
      if (state && Array.isArray(state.devices)) return state.devices;
      return null;
    }
    let devicesWinner = null;
    async function fetchDevices() {
      const apiNames = ["ConnectAggregatorAPI", "ConnectAPI", "RemoteDeviceAPI"];
      const methods = [
        "getDevices",
        "getAvailableDevices",
        "getState",
        "getCurrentState",
        "getDeviceState",
        "fetch"
      ];
      const attempts = [];
      for (const n of apiNames) {
        const api = apiOf(n);
        if (!api) continue;
        for (const m of methods) {
          if (typeof api[m] === "function") {
            attempts.push([`${n}.${m}()`, () => api[m]?.()]);
          }
        }
      }
      let raw = null;
      if (devicesWinner) {
        try {
          raw = await tryOne(devicesWinner.fn);
        } catch {
          devicesWinner = null;
        }
      }
      if (raw == null) {
        const hit = await probeAttempts(attempts);
        if (!hit) return [];
        devicesWinner = { label: hit.hit, fn: hit.fn };
        raw = hit.raw;
      }
      const arr = pickDeviceArray(raw);
      if (!arr) return [];
      const out = [];
      for (const item of arr) {
        const d = normalizeDevice(item);
        if (d) out.push(d);
      }
      return out;
    }
    async function transferPlayback(deviceId) {
      const candidates = [
        ["ConnectAPI", "transferPlayback"],
        ["ConnectAPI", "transfer"],
        ["ConnectAggregatorAPI", "transferPlayback"],
        ["ConnectAggregatorAPI", "transfer"],
        ["RemoteDeviceAPI", "transfer"]
      ];
      for (const [apiName, method] of candidates) {
        const api = apiOf(apiName);
        const fn = api?.[method];
        if (typeof fn !== "function") continue;
        try {
          await fn.call(api, deviceId);
          return;
        } catch {
        }
      }
    }
    function deviceIconName(type) {
      if (type === "smartphone") return "smartphone";
      if (type === "computer") return "computer";
      if (type === "speaker") return "speaker";
      return "device";
    }
    function renderDeviceRow(d) {
      const sub = [
        d.type === "smartphone" ? "Phone" : d.type === "computer" ? "Computer" : d.type === "speaker" ? "Speaker" : "Device",
        d.isLocal ? "This device" : null,
        d.isActive ? "Playing" : null
      ].filter(Boolean).join(" \xB7 ");
      const activeClass = d.isActive ? " crp-device-active" : "";
      return `
      <div class="crp-list-row crp-device-row${activeClass}" data-device-id="${escapeHtml(d.id)}">
        <div class="crp-device-icon">${icon(deviceIconName(d.type))}</div>
        <div class="crp-list-info">
          <span class="crp-list-name">${escapeHtml(d.name)}</span>
          <span class="crp-list-sub">${escapeHtml(sub)}</span>
        </div>
        <div class="crp-device-indicator" aria-hidden="true"></div>
      </div>`;
    }
    function renderDevices(list) {
      if (!panelEl) return;
      const container = panelEl.querySelector(".crp-devices-list");
      if (!container) return;
      if (list.length === 0) {
        container.innerHTML = '<div class="crp-empty">No devices available</div>';
        return;
      }
      const sorted = [...list].sort((a, b) => {
        if (a.isActive !== b.isActive) return a.isActive ? -1 : 1;
        if (a.isLocal !== b.isLocal) return a.isLocal ? -1 : 1;
        return a.name.localeCompare(b.name);
      });
      container.innerHTML = sorted.map(renderDeviceRow).join("");
    }
    function wireDevicesDelegation(container) {
      container.addEventListener("click", (e) => {
        const row = e.target.closest(
          ".crp-device-row"
        );
        if (!row) return;
        const id = row.dataset.deviceId;
        if (!id) return;
        if (row.classList.contains("crp-device-active")) return;
        container.querySelectorAll(".crp-device-row").forEach((r) => r.classList.remove("crp-device-active"));
        row.classList.add("crp-device-active");
        void transferPlayback(id).then(() => refreshDevices(true));
      });
    }
    let lastDevicesKey = "";
    async function refreshDevices(force = false) {
      const list = await fetchDevices();
      const key = list.map((d) => `${d.id}:${d.isActive ? 1 : 0}`).join("|");
      if (!force && key === lastDevicesKey) return;
      lastDevicesKey = key;
      renderDevices(list);
    }
    let cmEl = null;
    function closeContextMenu() {
      if (cmEl) {
        cmEl.remove();
        cmEl = null;
      }
      document.removeEventListener("mousedown", onCmDocMousedown, true);
      document.removeEventListener("keydown", onCmKeydown, true);
      window.removeEventListener("blur", closeContextMenu);
      window.removeEventListener("resize", closeContextMenu);
    }
    function onCmDocMousedown(e) {
      if (cmEl && !cmEl.contains(e.target)) closeContextMenu();
    }
    function onCmKeydown(e) {
      if (e.key === "Escape") closeContextMenu();
    }
    function showContextMenu(entries, x, y) {
      closeContextMenu();
      if (entries.length === 0) return;
      const menu = document.createElement("div");
      menu.className = "crp-ctxmenu";
      menu.innerHTML = entries.map((e) => {
        if ("separator" in e) return '<div class="crp-ctxmenu-sep"></div>';
        const cls = "crp-ctxmenu-item" + (e.danger ? " crp-ctxmenu-danger" : "");
        return `<button class="${cls}" type="button">${escapeHtml(e.label)}</button>`;
      }).join("");
      menu.addEventListener("contextmenu", (e) => e.preventDefault());
      document.body.appendChild(menu);
      const rect = menu.getBoundingClientRect();
      const px = Math.max(4, Math.min(x, window.innerWidth - rect.width - 4));
      const py = Math.max(4, Math.min(y, window.innerHeight - rect.height - 4));
      menu.style.left = `${px}px`;
      menu.style.top = `${py}px`;
      const items = entries.filter((e) => !("separator" in e));
      menu.querySelectorAll(".crp-ctxmenu-item").forEach((btn, i) => {
        btn.addEventListener("click", (ev) => {
          ev.stopPropagation();
          const entry = items[i];
          closeContextMenu();
          try {
            entry?.onClick();
          } catch {
          }
        });
      });
      cmEl = menu;
      document.addEventListener("mousedown", onCmDocMousedown, true);
      document.addEventListener("keydown", onCmKeydown, true);
      window.addEventListener("blur", closeContextMenu);
      window.addEventListener("resize", closeContextMenu);
    }
    function navigateUri(uri) {
      const path = uri.replace(/^spotify:/, "/").replace(/:/g, "/");
      Spicetify.Platform.History.push(path);
    }
    function uriToWebUrl(uri) {
      const parts = uri.split(":");
      if (parts.length < 3) return uri;
      return `https://open.spotify.com/${parts[1]}/${parts[2]}`;
    }
    function copyText(s) {
      navigator.clipboard?.writeText(s).catch(() => {
      });
    }
    async function addToQueueUri(uri) {
      const api = playerApi();
      if (!api?.addToQueue) return;
      try {
        await api.addToQueue([{ uri }]);
      } catch {
      }
      await refreshQueue(true);
    }
    async function toggleLikeFor(uri) {
      if (!uri.startsWith("spotify:track:")) return;
      const api = libraryApi();
      if (!api) return;
      const liked = await isLiked(uri);
      try {
        if (liked) await api.remove?.({ uris: [uri] });
        else await api.add?.({ uris: [uri] });
      } catch {
      }
      syncLikeState();
    }
    async function trackMenu(opts) {
      const { uri, artistUri, albumUri, queueIdx } = opts;
      const liked = await isLiked(uri);
      const items = [
        { label: "Play", onClick: () => Spicetify.Player.playUri(uri) },
        { label: "Add to queue", onClick: () => addToQueueUri(uri) },
        {
          label: liked ? "Remove from Liked Songs" : "Save to Liked Songs",
          onClick: () => toggleLikeFor(uri)
        }
      ];
      if (typeof queueIdx === "number" && queueIdx >= 0) {
        items.push({
          label: "Remove from queue",
          danger: true,
          onClick: () => removeFromQueue(queueIdx)
        });
      }
      if (albumUri || artistUri) items.push({ separator: true });
      if (albumUri) items.push({ label: "Go to album", onClick: () => navigateUri(albumUri) });
      if (artistUri) items.push({ label: "Go to artist", onClick: () => navigateUri(artistUri) });
      items.push({ separator: true });
      items.push({ label: "Copy Spotify URI", onClick: () => copyText(uri) });
      items.push({ label: "Copy link", onClick: () => copyText(uriToWebUrl(uri)) });
      return items;
    }
    function albumMenu(uri) {
      return [
        { label: "Play album", onClick: () => Spicetify.Player.playUri(uri) },
        { label: "Add to queue", onClick: () => addToQueueUri(uri) },
        { separator: true },
        { label: "Go to album", onClick: () => navigateUri(uri) },
        { separator: true },
        { label: "Copy Spotify URI", onClick: () => copyText(uri) },
        { label: "Copy link", onClick: () => copyText(uriToWebUrl(uri)) }
      ];
    }
    function artistMenu(uri) {
      return [
        { label: "Play artist", onClick: () => Spicetify.Player.playUri(uri) },
        { separator: true },
        { label: "Go to artist", onClick: () => navigateUri(uri) },
        { separator: true },
        { label: "Copy Spotify URI", onClick: () => copyText(uri) },
        { label: "Copy link", onClick: () => copyText(uriToWebUrl(uri)) }
      ];
    }
    function hrefToUri(href) {
      if (!href || !href.startsWith("/")) return "";
      const parts = href.replace(/^\//, "").split("/");
      if (parts.length < 2) return "";
      return `spotify:${parts[0]}:${parts[1]}`;
    }
    async function menuForRowEvent(e, row) {
      const link = e.target.closest("a.crp-link");
      if (link) {
        const uri = hrefToUri(link.getAttribute("href"));
        if (uri.startsWith("spotify:artist:")) return artistMenu(uri);
        if (uri.startsWith("spotify:album:")) return albumMenu(uri);
        if (uri.startsWith("spotify:track:")) {
          return trackMenu({ uri, artistUri: row.artistUri, albumUri: row.albumUri, queueIdx: row.queueIdx });
        }
      }
      return trackMenu(row);
    }
    function wirePlayerContextMenu(root) {
      const playerEl = root.querySelector(".crp-player");
      if (!playerEl) return;
      playerEl.addEventListener("contextmenu", (e) => {
        const target = e.target;
        if (target.closest("button, .crp-seek, .crp-vol-bar, .crp-cover")) return;
        const data = Spicetify.Player.data?.item;
        const uri = data?.uri;
        if (!uri) return;
        const meta = data?.metadata || {};
        const link = target.closest(".crp-link");
        e.preventDefault();
        if (link?.classList.contains("crp-track-artist") && meta.artist_uri) {
          showContextMenu(artistMenu(meta.artist_uri), e.clientX, e.clientY);
          return;
        }
        if (link?.classList.contains("crp-track-album") && meta.album_uri) {
          showContextMenu(albumMenu(meta.album_uri), e.clientX, e.clientY);
          return;
        }
        trackMenu({ uri, artistUri: meta.artist_uri, albumUri: meta.album_uri }).then(
          (items) => showContextMenu(items, e.clientX, e.clientY)
        );
      });
    }
    function mount(sidebar) {
      panelEl = build();
      sidebar.appendChild(panelEl);
      const queueList = panelEl.querySelector(".crp-queue-list");
      const recentList = panelEl.querySelector(".crp-recent-list");
      const friendsList = panelEl.querySelector(".crp-friends-list");
      const devicesList = panelEl.querySelector(".crp-devices-list");
      if (queueList) wireQueueDelegation(queueList);
      if (recentList) wireSimpleListDelegation(recentList);
      if (friendsList) wireFriendsDelegation(friendsList);
      if (devicesList) wireDevicesDelegation(devicesList);
      const recentPane = panelEl.querySelector(
        '.crp-tab-pane[data-pane="recent"]'
      );
      if (recentPane) wireRecentInfiniteScroll(recentPane);
      wirePlayerContextMenu(panelEl);
      syncTrackInfo();
      syncPlayPause();
      syncShuffleRepeat();
      syncVolume();
      syncLikeState();
      setActiveTab(activeTab);
      lastQueueKey = "";
      lastFriendsKey = "";
      recentItems = [];
      recentRawConsumed = 0;
      recentExhausted = false;
      recentLoading = false;
      refreshQueue(true);
      refreshRecent(true);
      refreshFriends(true);
    }
    maintainInjection({
      target: getRightSidebar,
      exists: () => document.getElementById("custom-right-panel"),
      mount: (sidebar) => {
        panelEl = null;
        mount(sidebar);
      }
    });
    Spicetify.Player.addEventListener("songchange", () => {
      logR(
        "songchange fired; new track =",
        Spicetify.Player.data?.item?.uri
      );
      syncTrackInfo();
      syncLikeState();
      refreshQueue();
    });
    Spicetify.Player.addEventListener("onplaypause", syncPlayPause);
    libraryApi()?.getEvents?.()?.addListener?.("update", syncLikeState);
    {
      const sources = ["RecentsAPI", "PlayHistoryAPI", "RecentlyPlayedAPI"];
      for (const name of sources) {
        const api = apiOf(name);
        if (!api) continue;
        const events = api.getEvents?.();
        const target = events ?? api;
        const add = target.addListener ?? target.on ?? target.subscribe;
        if (!add) {
          logR(`${name}: no listener-registration method (events?`, !!events, ")");
          continue;
        }
        try {
          add.call(target, "update", () => {
            logR(`${name} 'update' event fired \u2014 refreshing`);
            refreshRecent(false);
          });
          logR(`Subscribed to ${name} 'update' events via`, target === events ? "getEvents()" : "api direct");
        } catch (err) {
          logR(`Failed to subscribe to ${name}`, err);
        }
      }
    }
    if (DEBUG_RECENT) {
      for (const n of ["RecentsAPI", "PlayHistoryAPI", "RecentlyPlayedAPI"]) {
        const a = apiOf(n);
        if (!a) continue;
        const keys = Object.keys(a).join(", ");
        const proto = Object.getPrototypeOf(a);
        const protoKeys = proto ? Object.getOwnPropertyNames(proto).join(", ") : "(none)";
        logR(`API shape: ${n} own keys = [${keys}]; proto methods = [${protoKeys}]`);
        const evts = a.getEvents;
        if (typeof evts === "function") {
          try {
            const ev = evts.call(a);
            if (ev && typeof ev === "object") {
              const evKeys = Object.keys(ev).join(", ");
              const evProto = Object.getPrototypeOf(ev);
              const evProtoKeys = evProto ? Object.getOwnPropertyNames(evProto).join(", ") : "(none)";
              logR(
                `API shape: ${n}.getEvents() own = [${evKeys}]; proto = [${evProtoKeys}]`
              );
            } else {
              logR(`API shape: ${n}.getEvents() =`, ev);
            }
          } catch (err) {
            logR(`API shape: ${n}.getEvents() threw`, err);
          }
        }
      }
      void (async () => {
        const methods = ["getContents", "getRecentlyPlayed", "getPlayHistory", "getHistory"];
        const variants = [
          ["({limit:30})", [{ limit: 30 }]],
          ["({limit:30,offset:0})", [{ limit: 30, offset: 0 }]],
          ["({limit:30,offset:30})", [{ limit: 30, offset: 30 }]],
          ["(30)", [30]],
          ["(0,30)", [0, 30]],
          ["({pageSize:30,pageIndex:0})", [{ pageSize: 30, pageIndex: 0 }]],
          ["({first:30})", [{ first: 30 }]],
          ["({count:30})", [{ count: 30 }]]
        ];
        const results = [];
        for (const n of ["RecentsAPI", "PlayHistoryAPI", "RecentlyPlayedAPI"]) {
          const a = apiOf(n);
          if (!a) continue;
          for (const m of methods) {
            if (typeof a[m] !== "function") continue;
            for (const [argLabel, args] of variants) {
              try {
                const p = a[m](...args);
                if (!p || typeof p.then !== "function") continue;
                const res = await p;
                const arr = pickArray(res);
                if (arr) results.push({ label: `${n}.${m}${argLabel}`, count: arr.length });
              } catch {
              }
            }
          }
        }
        results.sort((a, b) => a.count - b.count);
        logR(`paginationProbe: ${results.length} successful calls`);
        for (const r of results) {
          logR(`  ${r.label} \u2192 count=${r.count}`);
        }
      })();
    }
    startProgressLoop();
    refreshQueue();
    refreshFriends();
    refreshDevices();
    window.setInterval(refreshQueue, 2e3);
    window.setInterval(refreshFriends, 3e4);
    window.setInterval(refreshDevices, 5e3);
    window.setInterval(() => {
      if (recentItems.length > 0) renderRecentList();
    }, 6e4);
    let lastShuffle = null;
    let lastRepeat = null;
    let lastVolume = -1;
    window.setInterval(() => {
      const sh = readShuffle();
      const rp = readRepeat();
      if (sh !== lastShuffle || rp !== lastRepeat) {
        lastShuffle = sh;
        lastRepeat = rp;
        syncShuffleRepeat();
      }
      const v = Spicetify.Player.getVolume();
      if (Math.abs(v - lastVolume) > 5e-3) {
        lastVolume = v;
        syncVolume();
      }
    }, 500);
    document.addEventListener("crp-switch-tab", (e) => {
      const detail = e.detail;
      if (detail) setActiveTab(detail);
    });
  })();
})();

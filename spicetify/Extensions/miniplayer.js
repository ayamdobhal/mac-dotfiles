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
  function getMiniplayerButton() {
    const attempts = [
      ['button[data-testid="mini-player-button"]', "testid"],
      ['button[data-testid*="miniplayer" i]', "testid"],
      ['button[data-testid*="mini-player" i]', "testid"],
      ['button[aria-label="Open Miniplayer" i]', "aria"],
      ['button[aria-label*="miniplayer" i]', "aria"],
      ['button[aria-label*="mini player" i]', "aria"]
    ];
    for (const [sel, method] of attempts) {
      const el = qs(sel);
      if (el) {
        logResolved("getMiniplayerButton", method, el);
        return el;
      }
    }
    return null;
  }

  // src/miniplayer.ts
  (async function miniplayer() {
    while (!Spicetify?.Player?.addEventListener || !Spicetify?.Player?.data) {
      await new Promise((r) => setTimeout(r, 100));
    }
    const FALLBACK_ICONS = {
      play: '<path d="M3 1.5v13l11-6.5z"/>',
      pause: '<path d="M2.7 1a.7.7 0 0 0-.7.7v12.6a.7.7 0 0 0 .7.7h2.6a.7.7 0 0 0 .7-.7V1.7a.7.7 0 0 0-.7-.7H2.7zm8 0a.7.7 0 0 0-.7.7v12.6a.7.7 0 0 0 .7.7h2.6a.7.7 0 0 0 .7-.7V1.7a.7.7 0 0 0-.7-.7h-2.6z"/>',
      "skip-back": '<path d="M3.3 1a.7.7 0 0 1 .7.7v5.4l8.4-5.6a1 1 0 0 1 1.6.8v11.4a1 1 0 0 1-1.6.8L4 8.9v5.4a.7.7 0 1 1-1.4 0V1.7a.7.7 0 0 1 .7-.7z"/>',
      "skip-forward": '<path d="M12.7 1a.7.7 0 0 0-.7.7v5.4L3.6 1.5A1 1 0 0 0 2 2.3v11.4a1 1 0 0 0 1.6.8L12 8.9v5.4a.7.7 0 1 0 1.4 0V1.7a.7.7 0 0 0-.7-.7z"/>',
      "chevron-down": '<path d="M14 5.5l-6 6-6-6 1-1 5 5 5-5z"/>',
      "chevron-up": '<path d="M14 10.5l-6-6-6 6 1 1 5-5 5 5z"/>',
      x: '<path d="M2.47 2.47a.75.75 0 0 1 1.06 0L8 6.94l4.47-4.47a.75.75 0 1 1 1.06 1.06L9.06 8l4.47 4.47a.75.75 0 1 1-1.06 1.06L8 9.06l-4.47 4.47a.75.75 0 0 1-1.06-1.06L6.94 8 2.47 3.53a.75.75 0 0 1 0-1.06z"/>'
    };
    function icon(name) {
      const inner = Spicetify.SVGIcons?.[name] ?? FALLBACK_ICONS[name] ?? "";
      return `<svg viewBox="0 0 16 16" fill="currentColor">${inner}</svg>`;
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
    function fmtTime(ms) {
      if (!isFinite(ms) || ms < 0) ms = 0;
      const s = Math.floor(ms / 1e3);
      const m = Math.floor(s / 60);
      return `${m}:${String(s % 60).padStart(2, "0")}`;
    }
    let pipWin = null;
    let pipRoot = null;
    let rafId = null;
    let seeking = false;
    let activeTab = "lyrics";
    let panelExpanded = true;
    let lastRenderedLyricsUri = null;
    let lastActiveLineIdx = -1;
    function isOpen() {
      return !!pipWin && !pipWin.closed;
    }
    async function openPip() {
      const docPiP = window.documentPictureInPicture;
      if (!docPiP || typeof docPiP.requestWindow !== "function") {
        getMiniplayerButton()?.click();
        return;
      }
      pipWin = await docPiP.requestWindow({ width: 360, height: 560 });
      for (const el of Array.from(
        document.querySelectorAll('link[rel="stylesheet"], style')
      )) {
        pipWin.document.head.appendChild(el.cloneNode(true));
      }
      pipWin.document.documentElement.lang = "en";
      pipWin.document.title = "Miniplayer";
      pipWin.document.body.className = "encore-dark-theme mp-pip-body";
      pipWin.document.body.style.margin = "0";
      pipWin.document.body.style.background = "rgba(20, 20, 20, 0.85)";
      pipWin.document.body.innerHTML = buildHtml();
      pipRoot = pipWin.document.body.querySelector("#mini-player");
      if (pipRoot) {
        wireControls(pipRoot);
        wireTabs(pipRoot);
        syncAll();
        if (activeTab === "lyrics") refreshLyrics();
        else refreshQueue();
        startProgressLoop();
      }
      pipWin.addEventListener("pagehide", onPipClosed);
    }
    function onPipClosed() {
      stopProgressLoop();
      pipWin = null;
      pipRoot = null;
      lastRenderedLyricsUri = null;
      lastActiveLineIdx = -1;
    }
    function closePip() {
      if (!pipWin) return;
      try {
        pipWin.close();
      } catch {
      }
      onPipClosed();
    }
    function toggle() {
      if (isOpen()) closePip();
      else void openPip();
    }
    function buildHtml() {
      const expandedClass = panelExpanded ? "expanded" : "collapsed";
      const chevron = panelExpanded ? "chevron-up" : "chevron-down";
      return `
      <div id="mini-player" class="mini-player ${expandedClass}">
        <button class="mp-close" aria-label="Close miniplayer">${icon("x")}</button>
        <div class="mp-compact">
          <div class="mp-art-wrap"><div class="mp-art"></div></div>
          <div class="mp-compact-right">
            <div class="mp-info">
              <div class="mp-title"></div>
              <div class="mp-artist"></div>
            </div>
            <div class="mp-seek">
              <span class="mp-time-elapsed">0:00</span>
              <div class="mp-seek-bar"><div class="mp-seek-fill"></div><div class="mp-seek-thumb"></div></div>
              <span class="mp-time-total">0:00</span>
            </div>
            <div class="mp-controls">
              <button class="mp-btn mp-prev" aria-label="Previous">${icon("skip-back")}</button>
              <button class="mp-btn mp-play-pause mp-primary" aria-label="Play/Pause">${icon("play")}</button>
              <button class="mp-btn mp-next" aria-label="Next">${icon("skip-forward")}</button>
            </div>
          </div>
          <button class="mp-toggle-panel" aria-label="Toggle tabs panel">${icon(chevron)}</button>
        </div>
        <div class="mp-panel">
          <div class="mp-tab-bar">
            <button class="mp-tab active" data-tab="lyrics">Lyrics</button>
            <button class="mp-tab" data-tab="queue">Queue</button>
          </div>
          <div class="mp-tab-content">
            <div class="mp-tab-pane active" data-pane="lyrics"></div>
            <div class="mp-tab-pane" data-pane="queue"></div>
          </div>
        </div>
      </div>
    `;
    }
    function togglePanel() {
      if (!pipRoot) return;
      panelExpanded = !panelExpanded;
      pipRoot.classList.toggle("expanded", panelExpanded);
      pipRoot.classList.toggle("collapsed", !panelExpanded);
      const btn = pipRoot.querySelector(".mp-toggle-panel");
      if (btn) {
        btn.innerHTML = icon(panelExpanded ? "chevron-up" : "chevron-down");
      }
      if (panelExpanded) {
        if (activeTab === "lyrics") refreshLyrics();
        else refreshQueue();
      }
    }
    function wireControls(el) {
      el.querySelector(".mp-play-pause")?.addEventListener(
        "click",
        () => Spicetify.Player.togglePlay()
      );
      el.querySelector(".mp-prev")?.addEventListener(
        "click",
        () => Spicetify.Player.back()
      );
      el.querySelector(".mp-next")?.addEventListener(
        "click",
        () => Spicetify.Player.next()
      );
      el.querySelector(".mp-toggle-panel")?.addEventListener("click", togglePanel);
      el.querySelector(".mp-close")?.addEventListener("click", closePip);
      const seekBar = el.querySelector(".mp-seek-bar");
      if (seekBar) {
        const seekFromEvent = (ev) => {
          const rect = seekBar.getBoundingClientRect();
          const frac = Math.max(
            0,
            Math.min(1, (ev.clientX - rect.left) / rect.width)
          );
          return frac * Spicetify.Player.getDuration();
        };
        seekBar.addEventListener("mousedown", (ev) => {
          seeking = true;
          updateSeekUI(seekFromEvent(ev), Spicetify.Player.getDuration());
          const doc = pipWin?.document ?? document;
          const onMove = (m) => {
            updateSeekUI(seekFromEvent(m), Spicetify.Player.getDuration());
          };
          const onUp = (m) => {
            doc.removeEventListener("mousemove", onMove);
            doc.removeEventListener("mouseup", onUp);
            Spicetify.Player.seek(Math.round(seekFromEvent(m)));
            seeking = false;
          };
          doc.addEventListener("mousemove", onMove);
          doc.addEventListener("mouseup", onUp);
        });
      }
    }
    function wireTabs(el) {
      el.querySelectorAll(".mp-tab").forEach((btn) => {
        btn.addEventListener("click", () => {
          const id = btn.dataset.tab;
          if (id) setActiveTab(id);
        });
      });
    }
    function setActiveTab(id) {
      if (!pipRoot) return;
      activeTab = id;
      pipRoot.querySelectorAll(".mp-tab").forEach((el) => {
        el.classList.toggle("active", el.dataset.tab === id);
      });
      pipRoot.querySelectorAll(".mp-tab-pane").forEach((el) => {
        el.classList.toggle("active", el.dataset.pane === id);
      });
      if (id === "lyrics") refreshLyrics();
      else refreshQueue();
    }
    function syncAll() {
      syncTrackInfo();
      syncPlayPause();
      syncSeek();
    }
    function syncTrackInfo() {
      if (!pipRoot) return;
      const track = Spicetify.Player.data?.item;
      const meta = track?.metadata || {};
      const cover = toHttpUrl(meta.image_large_url || meta.image_url) || "";
      const title = meta.title || track?.name || "";
      const artist = meta.artist_name || "";
      const artEl = pipRoot.querySelector(".mp-art");
      if (artEl) artEl.style.backgroundImage = cover ? `url('${cover}')` : "";
      const titleEl = pipRoot.querySelector(".mp-title");
      if (titleEl) titleEl.textContent = title;
      const artistEl = pipRoot.querySelector(".mp-artist");
      if (artistEl) artistEl.textContent = artist;
    }
    function syncPlayPause() {
      if (!pipRoot) return;
      const btn = pipRoot.querySelector(".mp-play-pause");
      if (!btn) return;
      const paused = Spicetify.Player.data?.isPaused ?? true;
      btn.innerHTML = icon(paused ? "play" : "pause");
    }
    function getAccurateProgress() {
      const data = Spicetify.Player.data;
      if (data?.position_as_of_timestamp != null && data.timestamp != null) {
        return data.isPaused ? data.position_as_of_timestamp : data.position_as_of_timestamp + (Date.now() - data.timestamp);
      }
      return Spicetify.Player.getProgress();
    }
    function updateSeekUI(posMs, durMs) {
      if (!pipRoot) return;
      const pct = durMs > 0 ? Math.max(0, Math.min(1, posMs / durMs)) : 0;
      const fill = pipRoot.querySelector(".mp-seek-fill");
      const thumb = pipRoot.querySelector(".mp-seek-thumb");
      const elapsed = pipRoot.querySelector(".mp-time-elapsed");
      const total = pipRoot.querySelector(".mp-time-total");
      if (fill) fill.style.width = `${pct * 100}%`;
      if (thumb) thumb.style.left = `${pct * 100}%`;
      if (elapsed) elapsed.textContent = fmtTime(posMs);
      if (total) total.textContent = fmtTime(durMs);
    }
    function syncSeek() {
      updateSeekUI(getAccurateProgress(), Spicetify.Player.getDuration());
    }
    function startProgressLoop() {
      if (rafId != null) return;
      const tick = () => {
        if (!seeking) syncSeek();
        if (activeTab === "lyrics") highlightLyricsLine();
        rafId = (pipWin ?? window).requestAnimationFrame(tick);
      };
      rafId = (pipWin ?? window).requestAnimationFrame(tick);
    }
    function stopProgressLoop() {
      if (rafId != null) (pipWin ?? window).cancelAnimationFrame(rafId);
      rafId = null;
    }
    const lyricsCache = /* @__PURE__ */ new Map();
    function parseLrc(lrc) {
      const out = [];
      for (const raw of lrc.split("\n")) {
        const m = raw.match(/^\[(\d+):(\d+(?:\.\d+)?)\](.*)/);
        if (!m) continue;
        const time = parseInt(m[1], 10) * 60 + parseFloat(m[2]);
        const text = m[3].replace(/<[^>]+>/g, "").trim();
        out.push({ time, text });
      }
      return out;
    }
    async function fetchLyrics(uri, name, artist, album, durationMs) {
      const cached = lyricsCache.get(uri);
      if (cached) return cached;
      if (!name || !artist) {
        const none2 = { type: "none" };
        lyricsCache.set(uri, none2);
        return none2;
      }
      const params = new URLSearchParams({
        track_name: name,
        artist_name: artist,
        album_name: album || "",
        duration: String(Math.round(durationMs / 1e3))
      });
      try {
        const res = await fetch(`https://lrclib.net/api/get?${params}`);
        if (res.ok) {
          const data = await res.json();
          if (data.syncedLyrics) {
            const val = {
              type: "synced",
              lines: parseLrc(data.syncedLyrics)
            };
            lyricsCache.set(uri, val);
            return val;
          }
          if (data.plainLyrics) {
            const val = { type: "unsynced", text: data.plainLyrics };
            lyricsCache.set(uri, val);
            return val;
          }
        }
      } catch {
      }
      const none = { type: "none" };
      lyricsCache.set(uri, none);
      return none;
    }
    async function refreshLyrics() {
      if (!pipRoot) return;
      const pane = pipRoot.querySelector('.mp-tab-pane[data-pane="lyrics"]');
      if (!pane) return;
      const track = Spicetify.Player.data?.item;
      if (!track?.uri) {
        pane.innerHTML = '<div class="mp-empty">Nothing playing</div>';
        return;
      }
      if (lastRenderedLyricsUri === track.uri) return;
      pane.innerHTML = '<div class="mp-empty">Loading lyrics\u2026</div>';
      const meta = track.metadata || {};
      const name = meta.title || track.name;
      const artist = meta.artist_name;
      const album = meta.album_title;
      const duration = track.duration?.milliseconds || parseInt(meta.duration ?? "0", 10) || 0;
      const lyrics = await fetchLyrics(track.uri, name, artist, album, duration);
      if (Spicetify.Player.data?.item?.uri !== track.uri) return;
      lastRenderedLyricsUri = track.uri;
      lastActiveLineIdx = -1;
      if (lyrics.type === "none") {
        pane.innerHTML = '<div class="mp-empty">Lyrics not available</div>';
        return;
      }
      if (lyrics.type === "unsynced") {
        pane.innerHTML = `<div class="mp-lyrics-unsynced">${lyrics.text.split("\n").map((l) => `<div class="mp-line-plain">${escapeHtml(l)}</div>`).join("")}</div>`;
        return;
      }
      pane.innerHTML = `<div class="mp-lyrics-synced">${lyrics.lines.map(
        (l, i) => `<div class="mp-line" data-idx="${i}">${escapeHtml(l.text) || "&#9834;"}</div>`
      ).join("")}</div>`;
    }
    function highlightLyricsLine() {
      if (!pipRoot) return;
      const track = Spicetify.Player.data?.item;
      if (!track?.uri) return;
      const cached = lyricsCache.get(track.uri);
      if (!cached || cached.type !== "synced") return;
      const progressSec = getAccurateProgress() / 1e3;
      let idx = -1;
      for (let i = 0; i < cached.lines.length; i++) {
        if (cached.lines[i].time <= progressSec) idx = i;
        else break;
      }
      if (idx === lastActiveLineIdx) return;
      lastActiveLineIdx = idx;
      const pane = pipRoot.querySelector('.mp-tab-pane[data-pane="lyrics"]');
      if (!pane) return;
      pane.querySelectorAll(".mp-line").forEach((el) => {
        const i = parseInt(el.dataset.idx ?? "-1", 10);
        el.classList.toggle("active", i === idx);
        el.classList.toggle("past", i < idx);
      });
      pane.querySelector(".mp-line.active")?.scrollIntoView({
        behavior: "smooth",
        block: "center"
      });
    }
    async function fetchQueue() {
      const platform = Spicetify.Platform;
      const api = platform?.PlayerAPI;
      let raw = [];
      if (api?.getQueue) {
        try {
          const s = await api.getQueue();
          const userQ = Array.isArray(s?.queued) ? s.queued : [];
          const nextUp = Array.isArray(s?.nextUp) ? s.nextUp : [];
          if (userQ.length || nextUp.length) raw = userQ.concat(nextUp);
          else if (Array.isArray(s?.nextTracks))
            raw = s.nextTracks;
        } catch {
        }
      }
      const out = [];
      for (const item of raw) {
        const n = normalizeQueueItem(item);
        if (n) out.push(n);
      }
      return out;
    }
    function normalizeQueueItem(item) {
      if (!item || typeof item !== "object") return null;
      const it = item;
      const contextTrack = it.contextTrack || it;
      const uri = contextTrack.uri || it.uri || "";
      if (!uri || !uri.startsWith("spotify:track:")) return null;
      const meta = contextTrack.metadata || it.metadata || {};
      const name = meta.title || it.name || "";
      const artist = meta.artist_name || "";
      const art = toHttpUrl(meta.image_small_url || meta.image_url) || "";
      return { uri, name, artist, art };
    }
    async function refreshQueue() {
      if (!pipRoot) return;
      const pane = pipRoot.querySelector('.mp-tab-pane[data-pane="queue"]');
      if (!pane) return;
      const list = await fetchQueue();
      if (list.length === 0) {
        pane.innerHTML = '<div class="mp-empty">Queue is empty</div>';
        return;
      }
      pane.innerHTML = `<div class="mp-queue-list">${list.map(
        (t) => `
          <div class="mp-queue-row">
            <div class="mp-queue-art" style="background-image: url('${t.art}');"></div>
            <div class="mp-queue-info">
              <div class="mp-queue-name">${escapeHtml(t.name)}</div>
              <div class="mp-queue-sub">${escapeHtml(t.artist)}</div>
            </div>
          </div>`
      ).join("")}</div>`;
    }
    Spicetify.Player.addEventListener("songchange", () => {
      lastRenderedLyricsUri = null;
      lastActiveLineIdx = -1;
      if (!isOpen()) return;
      syncTrackInfo();
      syncSeek();
      if (activeTab === "lyrics") refreshLyrics();
      else refreshQueue();
    });
    Spicetify.Player.addEventListener("onplaypause", () => {
      if (isOpen()) syncPlayPause();
    });
    document.addEventListener("toggle-miniplayer", toggle);
  })();
})();

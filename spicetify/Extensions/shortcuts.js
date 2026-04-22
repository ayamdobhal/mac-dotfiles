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
  function getMainView() {
    const byTestId = qs('[data-testid="main"]');
    if (byTestId) {
      logResolved("getMainView", "testid", byTestId);
      return byTestId;
    }
    const byClass = qs(".Root__main-view");
    if (byClass) {
      logResolved("getMainView", "class", byClass);
      return byClass;
    }
    return null;
  }
  function getSpotifyLyricsContainer() {
    const main = getMainView();
    if (!main) return null;
    const byTestId = qs('[data-testid*="lyrics" i]', main);
    if (byTestId) {
      logResolved("getSpotifyLyricsContainer", "testid", byTestId);
      return byTestId;
    }
    const byClass = qs(".lyrics-lyrics-container", main);
    if (byClass) {
      logResolved("getSpotifyLyricsContainer", "class", byClass);
      return byClass;
    }
    return null;
  }

  // src/shortcuts.ts
  (async function shortcuts() {
    while (!Spicetify?.Player || !Spicetify?.Platform?.History) {
      await new Promise((r) => setTimeout(r, 100));
    }
    const OFFSET_STEP_MS = 50;
    const TOAST_MS = 1500;
    const w = window;
    if (typeof w.__lyricsOffsetMs !== "number") w.__lyricsOffsetMs = 0;
    const BINDINGS = [
      { keys: "F1", desc: "Show this help" },
      { keys: "F2", desc: "Toggle lyrics view" },
      { keys: "Ctrl/\u2318 + K", desc: "Command palette" },
      { keys: "Ctrl/\u2318 + 1 / 2 / 3 / 4", desc: "Switch right-panel tab" },
      { keys: "Ctrl/\u2318 + Shift + A", desc: "Go to artist of current track" },
      { keys: "Ctrl/\u2318 + Shift + B", desc: "Go to album of current track" },
      { keys: "Ctrl/\u2318 + Shift + M", desc: "Open Marketplace" },
      { keys: "[ / ]", desc: "Nudge lyrics timing by \xB150ms" },
      { keys: "Space", desc: "Play / pause (native)" },
      { keys: "Ctrl/\u2318 + \u2190 / \u2192", desc: "Prev / next track (native)" },
      { keys: "Ctrl/\u2318 + \u2191 / \u2193", desc: "Volume (native)" },
      { keys: "Ctrl/\u2318 + Shift + \u2190 / \u2192", desc: "Seek (native)" },
      { keys: "Ctrl/\u2318 + L", desc: "Like track (native)" },
      { keys: "Ctrl/\u2318 + R", desc: "Toggle repeat (native)" },
      { keys: "Ctrl/\u2318 + S", desc: "Toggle shuffle (native)" }
    ];
    let helpEl = null;
    function buildHelp() {
      helpEl = document.createElement("div");
      helpEl.id = "shortcut-help";
      helpEl.className = "shortcut-help hidden";
      const rows = BINDINGS.map(
        (b) => `<div class="shortcut-row"><span class="shortcut-keys">${b.keys}</span><span class="shortcut-desc">${b.desc}</span></div>`
      ).join("");
      helpEl.innerHTML = `
      <div class="shortcut-backdrop"></div>
      <div class="shortcut-modal">
        <div class="shortcut-title">Keyboard shortcuts</div>
        <div class="shortcut-list">${rows}</div>
        <div class="shortcut-hint">F1 or Esc to close</div>
      </div>
    `;
      document.body.appendChild(helpEl);
      helpEl.querySelector(".shortcut-backdrop")?.addEventListener("click", hideHelp);
    }
    function showHelp() {
      helpEl?.classList.remove("hidden");
    }
    function hideHelp() {
      helpEl?.classList.add("hidden");
    }
    function toggleHelp() {
      if (!helpEl) return;
      if (helpEl.classList.contains("hidden")) showHelp();
      else hideHelp();
    }
    function isHelpOpen() {
      return !!helpEl && !helpEl.classList.contains("hidden");
    }
    let toastEl = null;
    let toastTimer = null;
    function showToast(msg) {
      if (!toastEl) {
        toastEl = document.createElement("div");
        toastEl.id = "shortcut-toast";
        toastEl.className = "shortcut-toast";
        document.body.appendChild(toastEl);
      }
      toastEl.textContent = msg;
      toastEl.classList.add("visible");
      if (toastTimer != null) window.clearTimeout(toastTimer);
      toastTimer = window.setTimeout(() => {
        toastEl?.classList.remove("visible");
      }, TOAST_MS);
    }
    function uriToPath(uri) {
      return uri.replace(/^spotify:/, "/").replace(/:/g, "/");
    }
    function hasMainViewLyrics() {
      return !!getSpotifyLyricsContainer();
    }
    function toggleLyrics() {
      const onLyrics = hasMainViewLyrics();
      if (onLyrics) {
        const tryBack = (remaining) => {
          if (!hasMainViewLyrics()) return;
          if (remaining <= 0) {
            Spicetify.Platform.History.push("/");
            return;
          }
          window.history.back();
          window.setTimeout(() => tryBack(remaining - 1), 120);
        };
        tryBack(3);
      } else {
        Spicetify.Platform.History.push("/lyrics");
      }
    }
    function jumpToArtist() {
      const uri = Spicetify.Player.data?.item?.metadata?.artist_uri;
      if (!uri) {
        showToast("No artist for current track");
        return;
      }
      Spicetify.Platform.History.push(uriToPath(uri));
    }
    function jumpToAlbum() {
      const uri = Spicetify.Player.data?.item?.metadata?.album_uri;
      if (!uri) {
        showToast("No album for current track");
        return;
      }
      Spicetify.Platform.History.push(uriToPath(uri));
    }
    function hasMarketplace() {
      const apps = Spicetify?.Config?.custom_apps;
      if (!Array.isArray(apps)) return false;
      return apps.some((a) => a?.toLowerCase() === "marketplace");
    }
    function openMarketplace() {
      if (!hasMarketplace()) {
        showToast("Marketplace not installed");
        return;
      }
      Spicetify.Platform.History.push("/marketplace");
    }
    function nudgeOffset(deltaMs) {
      w.__lyricsOffsetMs = (w.__lyricsOffsetMs ?? 0) + deltaMs;
      const val = w.__lyricsOffsetMs;
      const sign = val > 0 ? "+" : "";
      showToast(`Lyrics offset: ${sign}${val}ms`);
    }
    function shouldIgnoreEvent(e) {
      const t = e.target;
      if (!t) return false;
      const tag = t.tagName;
      if (tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT") return true;
      if (t.isContentEditable) return true;
      const palette = document.getElementById("command-palette");
      if (palette && !palette.classList.contains("hidden")) return true;
      return false;
    }
    document.addEventListener(
      "keydown",
      (e) => {
        if (e.key === "Escape" && isHelpOpen()) {
          e.preventDefault();
          hideHelp();
          return;
        }
        if (shouldIgnoreEvent(e)) return;
        const mod = e.metaKey || e.ctrlKey;
        if (e.key === "F1") {
          e.preventDefault();
          toggleHelp();
          return;
        }
        if (e.key === "F2") {
          e.preventDefault();
          toggleLyrics();
          return;
        }
        if (mod && e.shiftKey && !e.altKey) {
          const k = e.key.toLowerCase();
          if (k === "a") {
            e.preventDefault();
            jumpToArtist();
            return;
          }
          if (k === "b") {
            e.preventDefault();
            jumpToAlbum();
            return;
          }
          if (k === "m") {
            e.preventDefault();
            openMarketplace();
            return;
          }
        }
        if (mod && !e.shiftKey && !e.altKey) {
          const tabForKey = {
            "1": "queue",
            "2": "recent",
            "3": "friends",
            "4": "devices"
          };
          const tab = tabForKey[e.key];
          if (tab) {
            e.preventDefault();
            document.dispatchEvent(
              new CustomEvent("crp-switch-tab", { detail: tab })
            );
            return;
          }
        }
        if (!mod && !e.shiftKey && !e.altKey) {
          if (e.key === "[") {
            e.preventDefault();
            nudgeOffset(-OFFSET_STEP_MS);
            return;
          }
          if (e.key === "]") {
            e.preventDefault();
            nudgeOffset(OFFSET_STEP_MS);
            return;
          }
        }
      },
      true
    );
    buildHelp();
    document.addEventListener("toggle-lyrics", toggleLyrics);
  })();
})();

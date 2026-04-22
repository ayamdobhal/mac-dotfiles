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
  function onSubtreeMutation(root, cb, opts = { childList: true, subtree: true }) {
    let rafPending = false;
    const obs = new MutationObserver(() => {
      if (rafPending) return;
      rafPending = true;
      requestAnimationFrame(() => {
        rafPending = false;
        cb();
      });
    });
    obs.observe(root, opts);
    return () => obs.disconnect();
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
  function getMainViewBanner() {
    const main = getMainView();
    if (!main) return null;
    const candidates = main.querySelectorAll(
      '[style*="background-image"]'
    );
    for (const el of candidates) {
      const style = el.getAttribute("style") || "";
      if (!/url\(/i.test(style)) continue;
      if (/placeholder|gradient/i.test(style)) continue;
      const rect = el.getBoundingClientRect();
      if (rect.width >= 200 && rect.height >= 100 && rect.top < 400) {
        return el;
      }
    }
    return null;
  }
  function getSwitchToAudioButton() {
    const attempts = [
      ['button[data-testid="audio-video-switcher-audio"]', "testid"],
      ['button[data-testid*="switch-to-audio" i]', "testid"],
      ['button[data-testid*="audio-switcher" i]', "testid"],
      ['button[aria-label="Switch to audio" i]', "aria"],
      ['button[aria-label*="switch to audio" i]', "aria"]
    ];
    for (const [sel, method] of attempts) {
      const el = qs(sel);
      if (el) {
        logResolved("getSwitchToAudioButton", method, el);
        return el;
      }
    }
    return null;
  }

  // src/layout.ts
  (async function layout() {
    while (!Spicetify?.Player || !Spicetify?.Platform?.History) {
      await new Promise((r) => setTimeout(r, 100));
    }
    function syncPlaybackState() {
      const isPaused = Spicetify.Player.data?.isPaused ?? true;
      document.body.classList.toggle("playback-paused", isPaused);
    }
    Spicetify.Player.addEventListener("onplaypause", syncPlaybackState);
    syncPlaybackState();
    function forceAudioMode() {
      getSwitchToAudioButton()?.click();
    }
    forceAudioMode();
    Spicetify.Player.addEventListener("songchange", forceAudioMode);
    maintainInjection({
      target: getMainView,
      exists: () => document.getElementById("lyrics-slot"),
      mount: (mainView) => {
        const slot = document.createElement("div");
        slot.id = "lyrics-slot";
        mainView.appendChild(slot);
      }
    });
    function applyHeaderFade(scrollEl) {
      const banner = getMainViewBanner();
      if (!banner) return;
      const range = Math.max(1, window.innerHeight * 0.4);
      const opacity = Math.max(0, 1 - (scrollEl.scrollTop || 0) / range);
      banner.style.setProperty("opacity", String(opacity), "important");
    }
    document.addEventListener(
      "scroll",
      (e) => {
        const target = e.target;
        if (!target || !(target instanceof HTMLElement)) return;
        applyHeaderFade(target);
      },
      true
    );
    function updateLyricsRoute() {
      document.body.classList.toggle(
        "on-lyrics-route",
        !!getSpotifyLyricsContainer()
      );
    }
    updateLyricsRoute();
    onSubtreeMutation(document.body, () => {
      updateLyricsRoute();
      forceAudioMode();
    });
    Spicetify.Platform.History.listen?.(updateLyricsRoute);
  })();
})();

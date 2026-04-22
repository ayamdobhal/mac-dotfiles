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
  function getFriendActivityButton() {
    const attempts = [
      ['button[data-testid="buddy-feed-toggle"]', "testid"],
      ['button[aria-label="Friend Activity" i]', "aria"],
      ['button[aria-label*="Friend Activity" i]', "aria"],
      ['button[aria-label*="friend" i]', "aria"]
    ];
    for (const [sel, method] of attempts) {
      const el = qs(sel);
      if (el) {
        logResolved("getFriendActivityButton", method, el);
        return el;
      }
    }
    return null;
  }

  // src/top-bar.ts
  (async function topBar() {
    while (!Spicetify?.Player) {
      await new Promise((r) => setTimeout(r, 100));
    }
    const MARK_ATTR = "data-lyrics-btn";
    function lyricsIconInner() {
      return Spicetify.SVGIcons?.["lyrics"] ?? '<path d="M13.426 2.574a2.831 2.831 0 0 0-4.797 1.55l3.247 3.247a2.831 2.831 0 0 0 1.55-4.797zM10.5 8.118l-2.619-2.62A63303.13 63303.13 0 0 0 4.74 9.075L2.065 12.12a1.287 1.287 0 0 0 1.816 1.816l3.06-2.688 3.56-3.129zM7.12 4.094a4.331 4.331 0 1 1 4.786 4.786l-3.974 3.492-3.06 2.688a2.787 2.787 0 0 1-3.933-3.933l2.676-3.045 3.505-3.988z"/>';
    }
    function onClickToggle(e) {
      e.preventDefault();
      e.stopPropagation();
      document.dispatchEvent(new CustomEvent("toggle-lyrics"));
    }
    function swapButton(btn) {
      const clone = btn.cloneNode(true);
      clone.setAttribute(MARK_ATTR, "1");
      clone.setAttribute("aria-label", "Toggle lyrics");
      clone.setAttribute("title", "Toggle lyrics (F2)");
      const existingSvg = clone.querySelector("svg");
      if (existingSvg) {
        existingSvg.setAttribute("viewBox", "0 0 16 16");
        existingSvg.innerHTML = lyricsIconInner();
      } else {
        clone.innerHTML = `<svg viewBox="0 0 16 16" fill="currentColor" width="16" height="16">${lyricsIconInner()}</svg>`;
      }
      clone.addEventListener("click", onClickToggle);
      btn.replaceWith(clone);
      syncActive(clone);
    }
    function syncActive(btn) {
      const active = document.body.classList.contains("on-lyrics-route");
      btn.classList.toggle("lyrics-btn-active", active);
      btn.setAttribute("aria-pressed", active ? "true" : "false");
    }
    function ensureSwapped() {
      const existing = document.querySelector(`[${MARK_ATTR}="1"]`);
      if (existing && existing.isConnected) {
        syncActive(existing);
        return;
      }
      const btn = getFriendActivityButton();
      if (btn) swapButton(btn);
    }
    ensureSwapped();
    onSubtreeMutation(document.body, ensureSwapped);
    const classObs = new MutationObserver(() => {
      const el = document.querySelector(`[${MARK_ATTR}="1"]`);
      if (el) syncActive(el);
    });
    classObs.observe(document.body, {
      attributes: true,
      attributeFilter: ["class"]
    });
  })();
})();

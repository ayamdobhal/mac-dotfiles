"use strict";
(() => {
  // src/command-palette.ts
  (async function commandPalette() {
    while (!Spicetify?.Player || !Spicetify?.Platform || !Spicetify?.CosmosAsync) {
      await new Promise((r) => setTimeout(r, 100));
    }
    let paletteEl = null;
    let inputEl = null;
    let resultsEl = null;
    let results = [];
    let selectedIdx = 0;
    let searchTimer = null;
    const queryCache = /* @__PURE__ */ new Map();
    function escapeHtml(s) {
      const map = {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        '"': "&quot;",
        "'": "&#39;"
      };
      return String(s).replace(/[&<>"']/g, (c) => map[c]);
    }
    function inject() {
      paletteEl = document.createElement("div");
      paletteEl.id = "command-palette";
      paletteEl.className = "command-palette hidden";
      paletteEl.innerHTML = `
      <div class="cmd-backdrop"></div>
      <div class="cmd-modal">
        <input id="cmd-input" type="text"
               placeholder="Search tracks, albums, artists, playlists\u2026"
               autocomplete="off" spellcheck="false" />
        <div id="cmd-results" class="cmd-results"></div>
      </div>
    `;
      document.body.appendChild(paletteEl);
      inputEl = paletteEl.querySelector("#cmd-input");
      resultsEl = paletteEl.querySelector("#cmd-results");
      inputEl?.addEventListener("input", onInput);
      inputEl?.addEventListener("keydown", onKeyDown);
      paletteEl.querySelector(".cmd-backdrop")?.addEventListener("click", hide);
    }
    function show() {
      if (!paletteEl || !inputEl) return;
      paletteEl.classList.remove("hidden");
      inputEl.value = "";
      inputEl.focus();
      results = [];
      selectedIdx = 0;
      renderResults();
    }
    function hide() {
      paletteEl?.classList.add("hidden");
    }
    function toggle() {
      if (!paletteEl) return;
      if (paletteEl.classList.contains("hidden")) show();
      else hide();
    }
    function onInput(e) {
      const query = e.target.value.trim();
      if (searchTimer !== null) window.clearTimeout(searchTimer);
      if (!query) {
        results = [];
        renderResults();
        return;
      }
      searchTimer = window.setTimeout(() => search(query), 250);
    }
    function imgFromUri(uri) {
      if (!uri) return "";
      if (uri.startsWith("spotify:image:")) {
        return "https://i.scdn.co/image/" + uri.slice("spotify:image:".length);
      }
      return uri;
    }
    function pickImage(sources) {
      if (!sources) return "";
      const small = sources[2]?.url || sources[1]?.url || sources[0]?.url;
      return imgFromUri(small || "");
    }
    async function search(query) {
      const cached = queryCache.get(query);
      if (cached) {
        results = cached;
        selectedIdx = 0;
        renderResults();
        return;
      }
      const gql = Spicetify.GraphQL;
      const def = gql?.Definitions?.searchModalResults;
      if (!gql?.Request || !def) return;
      try {
        const res = await gql.Request(def, {
          searchTerm: query,
          offset: 0,
          limit: 5,
          numberOfTopResults: 5,
          includeAudiobooks: false,
          includeAuthors: false,
          includePreReleases: false,
          includeLocalConcertsField: false,
          includeArtistHasConcertsField: false
        });
        const topItems = res?.data?.searchV2?.topResultsV2?.itemsV2 ?? [];
        if (!Array.isArray(topItems)) return;
        const items = [];
        const artistNames = (as) => (as ?? []).map((a) => a.profile?.name ?? "").filter(Boolean).join(", ");
        for (const entry of topItems) {
          const wrapper = entry.item;
          const d = wrapper?.data;
          if (!d) continue;
          switch (wrapper.__typename) {
            case "TrackResponseWrapper":
              items.push({
                type: "track",
                uri: d.uri,
                name: d.name,
                meta: artistNames(d.artists?.items),
                art: pickImage(d.albumOfTrack?.coverArt?.sources)
              });
              break;
            case "AlbumResponseWrapper":
              items.push({
                type: "album",
                uri: d.uri,
                name: d.name,
                meta: artistNames(d.artists?.items),
                art: pickImage(d.coverArt?.sources)
              });
              break;
            case "ArtistResponseWrapper":
              items.push({
                type: "artist",
                uri: d.uri,
                name: d.profile?.name ?? d.name,
                meta: "Artist",
                art: pickImage(d.visuals?.avatarImage?.sources)
              });
              break;
            case "PlaylistResponseWrapper":
              items.push({
                type: "playlist",
                uri: d.uri,
                name: d.name,
                meta: `By ${d.ownerV2?.data?.name ?? "Unknown"}`,
                art: pickImage(d.images?.items?.[0]?.sources)
              });
              break;
          }
        }
        queryCache.set(query, items);
        results = items;
        selectedIdx = 0;
        renderResults();
      } catch {
      }
    }
    function renderResults() {
      if (!resultsEl) return;
      if (results.length === 0) {
        resultsEl.innerHTML = "";
        return;
      }
      resultsEl.innerHTML = results.map(
        (r, i) => `
        <div class="cmd-result${i === selectedIdx ? " selected" : ""}" data-idx="${i}">
          <div class="cmd-result-art" style="background-image: url('${r.art}');"></div>
          <div class="cmd-result-info">
            <span class="cmd-result-name">${escapeHtml(r.name)}</span>
            <span class="cmd-result-meta">${escapeHtml(r.meta)}</span>
          </div>
          <span class="cmd-result-type">${r.type}</span>
        </div>
      `
      ).join("");
      resultsEl.querySelectorAll(".cmd-result").forEach((el) => {
        el.addEventListener("click", () => {
          selectedIdx = parseInt(el.dataset.idx ?? "0", 10);
          act();
        });
      });
      resultsEl.querySelector(".cmd-result.selected")?.scrollIntoView({ block: "nearest" });
    }
    function onKeyDown(e) {
      if (e.key === "Escape") {
        e.preventDefault();
        hide();
        return;
      }
      if (results.length === 0) return;
      if (e.key === "ArrowDown") {
        e.preventDefault();
        selectedIdx = (selectedIdx + 1) % results.length;
        renderResults();
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        selectedIdx = (selectedIdx - 1 + results.length) % results.length;
        renderResults();
      } else if (e.key === "Enter") {
        e.preventDefault();
        act();
      }
    }
    function act() {
      const item = results[selectedIdx];
      if (!item) return;
      if (item.type === "track") {
        Spicetify.Player.playUri(item.uri);
        hide();
        return;
      }
      const path = item.uri.replace(/^spotify:/, "/").replace(/:/g, "/");
      Spicetify.Platform.History.push(path);
      hide();
    }
    document.addEventListener(
      "keydown",
      (e) => {
        const mod = e.metaKey || e.ctrlKey;
        if (mod && e.key.toLowerCase() === "k") {
          e.preventDefault();
          e.stopPropagation();
          e.stopImmediatePropagation();
          toggle();
          return;
        }
      },
      true
    );
    inject();
  })();
})();

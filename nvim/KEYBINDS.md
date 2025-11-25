# 🧠 Neovim Keybind Cheatsheet

> **Terminal**: Ghostty  
> **Editor**: Neovim  
> **Leader Key**: `Space`  
> **Theme**: Tokyo Night (transparent)  
> **Style**: VS Code muscle memory + Vim power  

---

## 🔍 Search & Navigation

| Action | Key | Alternative |
|--------|-----|-------------|
| Find files in project | **⌘P** | `Ctrl + P` |
| Search in current file | **⌘F** | `Ctrl + F` |
| Search across project | **⌘⇧F**, `Space + sf` | — |
| Toggle file explorer | `Space + e` | — |
| List open buffers | `Space + fb` | — |
| Show help tags | `Space + fh` | — |

### 🔎 Inside Telescope (insert mode)

| Action | Key |
|--------|-----|
| Move selection down | `Ctrl + j` |
| Move selection up | `Ctrl + k` |
| Confirm selection | `Enter` |

---

## 🪟 Split & Window Management

### 🔧 Leader-based splits

| Action | Key |
|--------|-----|
| Vertical split | `Space + sv` |
| Horizontal split | `Space + sh` |
| Equalize all splits | `Space + se` |
| Close current split | `Space + sx` |

### 🔁 Move between splits (defaults)

| Action | Key |
|--------|-----|
| Move left | `Ctrl + h` |
| Move down | `Ctrl + j` |
| Move up | `Ctrl + k` |
| Move right | `Ctrl + l` |

### ↔ Resize splits (defaults)

| Action | Keys |
|--------|------|
| Increase width | `Ctrl + w` then `>` |
| Decrease width | `Ctrl + w` then `<` |
| Increase height | `Ctrl + w` then `+` |
| Decrease height | `Ctrl + w` then `-` |
| Equalize sizes | `Ctrl + w` then `=` |

---

## 🧠 LSP (Language Server)

> Works for Rust, Elixir, TS/JS, Python.

| Action | Keys |
|--------|-----|
| Go to definition | `gd` |
| Hover docs | `K` |
| Find references | `gr` |
| Rename symbol | `F2`, `Space + rn` |
| Code actions (quick fixes, refactors) | `Space + ca` |
| Format buffer | `Space + f` |

---

## ⚠️ Diagnostics (Errors & Warnings)

| Action | Keys |
|--------|-----|
| Show diagnostics popup | `Space + d` |
| Next diagnostic | `]d` |
| Previous diagnostic | `[d` |

> Inline messages (● …) are auto-shown at end of line.

---

## 💬 Comments

| Action | Mode | Key |
|--------|------|-----|
| Toggle comment | Normal | `Space + /` |
| Comment selection | Visual | Select → `Space + /` |

---

## 🧩 Buffer Management

| Action | Keys |
|--------|-----|
| Close buffer | `Space + q` |
| Next buffer | `Space + bn` |
| Previous buffer | `Space + bp` |

---

## 📎 Clipboard

| Action | Keys |
|--------|-----|
| Yank/copy to system clipboard | `"+y` |
| Paste from system clipboard | `"+p` |

---

## ⏪ Undo & Redo

| Action | Keys |
|--------|-----|
| Undo | `u` |
| Redo | `Ctrl + r` |
| Step backward in history | `g-` |
| Step forward in history | `g+` |

> 🔒 **Persistent undo** is enabled across sessions.

---

## 🧱 Vim Editing Essentials (Developer Must-Knows)

### ✂️ Delete

| Action | Keys | Notes |
|--------|------|-------|
| Delete line | `dd` | `3dd` deletes 3 lines |
| Delete word | `dw` | Forward direction |
| Delete word backwards | `db` | |
| Delete to end of line | `D` | same as `d$` |
| Delete inside quotes/parens | `di"` `di(` `di{` | VERY useful |
| Delete including quotes/parens | `da"` `da(` `da{` | |

### ✏️ Change (delete + insert)

| Action | Keys |
|--------|------|
| Change inside word | `ciw` |
| Change inside quotes/parens | `ci"` `ci(` `ci{` |
| Change to end of line | `C` (same as `c$`) |

### 📄 Copy (Yank) & Paste

| Action | Keys |
|--------|-----|
| Yank/copy line | `yy` |
| Yank word | `yw` |
| Paste after cursor | `p` |
| Paste before cursor | `P` |

### 🔍 Searching

| Action | Keys |
|--------|------|
| Search | `/text` |
| Next match | `n` |
| Previous match | `N` |
| Search for word under cursor | `*` |
| Visual select → search | Select → `*` |

---

## 🧾 File & Buffer Basics

| Action | Command |
|--------|---------|
| Open/create file | `:e filename` |
| New empty buffer | `:enew` then `:w filename` |
| Open file in vertical split | `:vsplit filename` |
| Open file in horizontal split | `:split filename` |

---

## ❓ Cheatsheet Popup

| Action | Keys |
|--------|-----|
| Open this cheatsheet | `Space + ?` |
| Close popup | `q` or `Esc` |

---

### 🎉 Done!

If you add new keybinds in the future, just send your `init.lua` and I’ll regenerate this automatically. Want a **printable PDF version** too? 📄✨


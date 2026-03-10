# Neovim Keybind Cheatsheet

> Leader Key: `Space`

---

## Search & Navigation (fzf-lua)

| Action | Key |
|--------|-----|
| Find files | `Ctrl+P` / `Cmd+P` |
| Search in current file | `Ctrl+F` / `Cmd+F` |
| Search across project | `Space sf` / `Cmd+Shift+F` |
| List open buffers | `Space fb` |
| Help tags | `Space fh` |

### Filtering in live grep

| Filter | Example |
|--------|---------|
| By file type | `search term -- -t ts` |
| By glob | `search term -- -g "*.tsx"` |
| By directory | `search term -- -g "src/**"` |
| Exclude pattern | `search term -- -g "!*.test.*"` |
| Combine | `useState -- -t tsx -g "src/**"` |

---

## File Explorer (Oil)

| Action | Key |
|--------|-----|
| Open file explorer | `Space e` / `-` |
| Go up a directory | `-` |
| Open file/directory | `Enter` |
| Create file | Type new name, save with `:w` |
| Delete file | Delete the line, save with `:w` |
| Rename file | Edit the name, save with `:w` |

---

## Harpoon (Quick File Switching)

| Action | Key |
|--------|-----|
| Mark current file | `Space a` |
| Open harpoon menu | `Space h` |
| Jump to file 1 | `Space 1` |
| Jump to file 2 | `Space 2` |
| Jump to file 3 | `Space 3` |
| Jump to file 4 | `Space 4` |

---

## LSP (Language Server)

> Works for Rust, TypeScript/JS, Python, Elixir.

| Action | Key |
|--------|-----|
| Go to definition | `gd` |
| Find references | `gr` |
| Hover docs | `K` |
| Rename symbol | `F2` / `Space rn` |
| Code actions | `Space ca` |
| Format buffer | `Space f` |

---

## Diagnostics & Trouble

| Action | Key |
|--------|-----|
| Line diagnostic popup | `Space d` |
| Next diagnostic | `]d` |
| Previous diagnostic | `[d` |
| Project diagnostics panel | `Space tt` |
| Buffer diagnostics panel | `Space td` |
| TODOs panel | `Space to` |

---

## Surround

| Action | Key | Example |
|--------|-----|---------|
| Change surrounding | `cs<old><new>` | `cs"'` changes `"hello"` to `'hello'` |
| Delete surrounding | `ds<char>` | `ds"` changes `"hello"` to `hello` |
| Add surrounding | `ys<motion><char>` | `ysiw)` wraps word in `()` |
| Add surrounding (line) | `yss<char>` | `yss)` wraps entire line in `()` |
| Surround in visual mode | Select, then `S<char>` | `S"` wraps selection in `""` |

---

## Comments (built-in)

| Action | Mode | Key |
|--------|------|-----|
| Toggle comment line | Normal | `gcc` |
| Toggle comment (motion) | Normal | `gc<motion>` (e.g. `gcap` for paragraph) |
| Toggle comment selection | Visual | Select, then `gc` |

---

## Find & Replace

| Action | Command |
|--------|---------|
| Replace first on line | `:s/old/new` |
| Replace all on line | `:s/old/new/g` |
| Replace all in file | `:%s/old/new/g` |
| Replace with confirm | `:%s/old/new/gc` |
| Replace in visual selection | Select, then `:s/old/new/g` |
| Case insensitive replace | `:%s/old/new/gi` |
| Replace word under cursor | `*` then `:%s//new/g` |

> Live preview is enabled — you'll see changes as you type.

---

## Splits & Windows

| Action | Key |
|--------|-----|
| Vertical split | `Space sv` |
| Horizontal split | `Space sh` |
| Equalize splits | `Space se` |
| Close split | `Space sx` |
| Move left/down/up/right | `Ctrl+h/j/k/l` |
| Resize width | `Ctrl+w >` / `Ctrl+w <` |
| Resize height | `Ctrl+w +` / `Ctrl+w -` |

---

## Buffers

| Action | Key |
|--------|-----|
| Close buffer | `Space q` |
| Next buffer | `Space bn` |
| Previous buffer | `Space bp` |

---

## Git

| Action | Key |
|--------|-----|
| Toggle inline blame | `Space gb` |

> Gitsigns shows +/- in the left gutter automatically.

---

## Undo & Redo

| Action | Key |
|--------|-----|
| Undo | `u` |
| Redo | `Ctrl+r` |
| Undo tree (visual) | `Space u` |

> Persistent undo is enabled — history survives closing files.

---

## Vim Editing Essentials

### Movement

| Action | Key |
|--------|-----|
| Word forward/back | `w` / `b` |
| End of word | `e` |
| Start/end of line | `0` / `$` |
| First non-blank char | `^` |
| Top/middle/bottom of screen | `H` / `M` / `L` |
| Jump to matching bracket | `%` |
| Jump to line number | `:<number>` or `<number>G` |

### Delete

| Action | Key |
|--------|-----|
| Delete line | `dd` (3dd = 3 lines) |
| Delete word forward/back | `dw` / `db` |
| Delete to end of line | `D` |
| Delete inside quotes/parens | `di"` / `di(` / `di{` |
| Delete around quotes/parens | `da"` / `da(` / `da{` |

### Change (delete + enter insert)

| Action | Key |
|--------|-----|
| Change word | `ciw` |
| Change inside quotes/parens | `ci"` / `ci(` / `ci{` |
| Change to end of line | `C` |
| Change entire line | `cc` |

### Copy & Paste

| Action | Key |
|--------|-----|
| Yank (copy) line | `yy` |
| Yank word | `yw` |
| Yank inside quotes | `yi"` |
| Paste after/before | `p` / `P` |
| Paste from system clipboard | Already automatic (clipboard shared) |

### Search

| Action | Key |
|--------|-----|
| Search forward/backward | `/text` / `?text` |
| Next/previous match | `n` / `N` |
| Word under cursor | `*` (forward) / `#` (backward) |
| Clear search highlight | `:noh` |

> Search is smart-case: lowercase = case insensitive, any uppercase = exact match.

### Visual Mode

| Action | Key |
|--------|-----|
| Visual character select | `v` |
| Visual line select | `V` |
| Visual block select | `Ctrl+v` |
| Select inside quotes/parens | `vi"` / `vi(` / `vi{` |
| Indent/unindent selection | `>` / `<` |
| Re-select last selection | `gv` |

### Marks

| Action | Key |
|--------|-----|
| Set mark | `m<letter>` (e.g. `ma`) |
| Jump to mark | `'<letter>` (e.g. `'a`) |
| Jump to exact position | `` `<letter> `` |
| List all marks | `:marks` |

### Macros

| Action | Key |
|--------|-----|
| Record macro | `q<letter>` (e.g. `qa`) |
| Stop recording | `q` |
| Play macro | `@<letter>` (e.g. `@a`) |
| Replay last macro | `@@` |
| Run macro N times | `10@a` |

---

## File Operations

| Action | Command |
|--------|---------|
| Save | `:w` |
| Save and quit | `:wq` or `ZZ` |
| Quit without saving | `:q!` or `ZQ` |
| Open/create file | `:e filename` |
| Open in split | `:vsplit filename` / `:split filename` |

---

## Cheatsheet

| Action | Key |
|--------|-----|
| Open this cheatsheet | `Space ?` |
| Close popup | `q` or `Esc` |

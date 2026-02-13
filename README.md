# tsm

`tsm` is a tmux-first workflow tool that serves as a **tmux-native replacement for ToggleTerm** and other Neovim/Vim floating terminal plugins. It brings the popup/panel workflow directly to tmux, making it editor-agnostic and available in any tmux session.

Focused on three fast actions:

- popup session attach/create
- persistent paneling (bottom/left/right)
- git worktree switching

## Highlights

### Basic session switcher (`tsm list` + `tsm kill`)

Quickly list and manage top-level tmux sessions.

- `tsm list`
- `tsm kill <session>`

### Popup session (`tsm popup`)

Open or reuse a floating tmux session tied to the current session/window.

- `tsm popup`
- `tsm popup "nvim"`
- `tsm popup "lazygit"`

### Persistent panel (`tsm panel toggle`)

Toggle a panel without losing process state.

- `tsm panel toggle`
- `tsm panel toggle --direction left`
- `tsm panel toggle --direction right`

### Worktree switch/create (`tsm worktree`)

Interactive picker for existing worktrees and branch-based worktree creation.

- `tsm worktree`
- `tsm worktree next`
- `tsm worktree prev`

## Screencasts

https://github.com/user-attachments/assets/fff13e31-5b20-434b-9e34-33f9d08cd60e

Popup workflow (`docs/screencasts/tsm_popup.mp4`)



https://github.com/user-attachments/assets/73c20f45-4d63-4c15-a388-c180c3c41642

Bottom panel workflow (`docs/screencasts/tsm_bottom_panel.mp4`)



https://github.com/user-attachments/assets/53bb648e-2107-45b4-ba2e-1a2059b91bb6

Side panel workflow (`docs/screencasts/tsm_side_panel.mp4`)

## Install

### Homebrew (tap)

```bash
brew install yukaii/tap/tsm
```

### Manual

```bash
git clone https://github.com/Yukaii/tsm.git
cd tsm
make build
cp ./tsm /usr/local/bin/tsm
```

## Usage

```text
Usage: tsm <command> [options]

Commands:
  list
  kill <session>
  popup [command]
  panel toggle [--direction <bottom|left|right>]
  worktree|wt
  help [command]
```

## tmux config example

```tmux
# popup
bind-key "'" run-shell -b "tsm popup"

# persistent panel
bind-key b run-shell -b "tsm panel toggle --direction bottom"
bind-key "(" run-shell -b "tsm panel toggle --direction left"
bind-key ")" run-shell -b "tsm panel toggle --direction right"

# worktree picker/cycle
bind-key w run-shell 'cd "#{pane_current_path}" && tsm worktree'
bind-key N run-shell 'cd "#{pane_current_path}" && tsm worktree next'
bind-key P run-shell 'cd "#{pane_current_path}" && tsm worktree prev'

# session switcher with kill support
bind-key r run-shell "echo $(tsm list | fzf-tmux -p 55%,60% \
  --no-sort --border-label ' Tmux session manager ' \
  --prompt '🔗  ' \
  --header '  Enter to attach to session, ^x to kill, Esc to cancel' \
  --bind 'enter:execute(tmux switch-client -t {})+abort'\
  --bind 'ctrl-x:execute(tsm kill {})+reload(tsm list)'\
) > /dev/null"

# smart popup toggle (auto-detach if already in floating session)
bind "'" if-shell "[[ $(tmux display-message -p '#S') = floating* ]]" {
    detach-client
} {
  run-shell "tsm popup"
}
```

## Editor integration examples

### Neovim (init.lua)

```lua
-- TSM popup keymaps
vim.keymap.set('n', '<leader>tl', ':silent !tsm popup lazygit<CR>', { desc = 'Lazygit popup' })
vim.keymap.set('n', '<leader>tf', ':silent !tsm popup<CR>', { desc = 'Terminal popup' })
vim.keymap.set('n', '<leader>tj', ':silent !tsm popup lazyjj<CR>', { desc = 'Lazyjj popup' })
vim.keymap.set('n', '<leader>tr', ':silent !tsm popup serpl<CR>', { desc = 'Serpl popup' })
```

### Helix (config.toml)

```toml
[keys.normal]
# TSM popup shortcuts
"," = { l = ":sh tsm popup lazygit", f = ":sh tsm popup", j = ":sh tsm popup lazyjj", r = ":sh tsm popup serpl" }
```

### Kakoune (kakrc)

```kak
# TSM popup commands
define-command -hidden tsm-popup-git %{
    (tsm popup lazygit &) >/dev/null 2>/dev/null
}
define-command -hidden tsm-popup-terminal %{
    (tsm popup &) >/dev/null 2>/dev/null
}
map global user g ': tsm-popup-git<ret>' -docstring 'Open lazygit in popup'
map global user f ': tsm-popup-terminal<ret>' -docstring 'Open terminal popup'
```

## Ghostty config example

Example Ghostty keybinds that send your tmux prefix bytes followed by the tsm-bound tmux keys.

```ini
# Prefix bytes reference:
# C-q => \x11
# C-b => \x02
# C-a => \x01

# Example: C-q prefix (custom)
keybind = ctrl+apostrophe=text:\x11'         # tsm popup
keybind = ctrl+grave_accent=text:\x11b       # panel bottom
keybind = ctrl+alt+w=text:\x11w              # worktree picker
keybind = ctrl+alt+shift+n=text:\x11N        # worktree next
keybind = ctrl+alt+shift+p=text:\x11P        # worktree prev

# Example: C-b prefix (default tmux)
keybind = ctrl+apostrophe=text:\x02'
keybind = ctrl+grave_accent=text:\x02b
keybind = ctrl+alt+w=text:\x02w
keybind = ctrl+alt+shift+n=text:\x02N
keybind = ctrl+alt+shift+p=text:\x02P

# Example: C-a prefix (common alternative)
keybind = ctrl+apostrophe=text:\x01'
keybind = ctrl+grave_accent=text:\x01b
keybind = ctrl+alt+w=text:\x01w
keybind = ctrl+alt+shift+n=text:\x01N
keybind = ctrl+alt+shift+p=text:\x01P
```

## Development

`tsm` is generated by `scripts/build.sh` and is intentionally not tracked in git.

```bash
make build
make lint
make test-integration
make test
```

## Docs

- Release + Homebrew automation: `docs/release-automation.md`

## Requirements

- bash
- tmux
- git
- fzf/fzf-tmux (for interactive worktree selection)

## License

MIT

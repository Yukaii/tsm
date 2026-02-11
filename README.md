# tsm

`tsm` is a tmux-first workflow tool focused on three fast actions:

- popup session attach/create
- persistent paneling (bottom/left/right)
- git worktree switching

## Highlights

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
```

## Ghostty config example

Example Ghostty keybinds that send your tmux prefix (`C-q`, `\x11`) followed by the tsm-bound tmux keys:

```ini
# tsm popup (tmux key: ')
keybind = ctrl+apostrophe=text:\x11'

# tsm panel bottom (tmux key: b)
keybind = ctrl+grave_accent=text:\x11b

# tsm worktree picker/next/prev (tmux keys: w, N, P)
keybind = ctrl+alt+w=text:\x11w
keybind = ctrl+alt+shift+n=text:\x11N
keybind = ctrl+alt+shift+p=text:\x11P
```

Adjust these if your tmux prefix is not `C-q`.

## Development

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

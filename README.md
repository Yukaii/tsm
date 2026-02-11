# tsm

`tsm` is a tmux helper focused on fast session/worktree navigation and a persistent panel toggle.

## Features

- `list`: list unique tmux session names
- `kill <name>`: kill matching sessions by base name
- `popup [command]`: open or reuse floating popup sessions
- `panel toggle`: persistent panel that can hide/show without losing process state
- `worktree` / `wt`: git worktree picker/create/switch flow

## Install

### Homebrew (tap)

After publishing a formula in your tap:

```bash
brew install Yukaii/tap/tsm
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

Examples:

```bash
tsm panel toggle
tsm panel toggle --direction left
tsm worktree
tsm worktree next
tsm popup "nvim"
```

## Tmux config

Reference bindings are in `/Users/yukai/Projects/Personal/tsm/fixtures/tmux.test.conf`.

Typical bindings:

```tmux
bind-key -n C-\\ run-shell "tsm panel toggle"
bind-key -n M-h run-shell "tsm panel toggle --direction left"
bind-key -n M-l run-shell "tsm panel toggle --direction right"
```

## Development

### Source layout

The repository is modular in `src/lib/`:

- `/Users/yukai/Projects/Personal/tsm/src/lib/sessions.sh`
- `/Users/yukai/Projects/Personal/tsm/src/lib/worktree.sh`
- `/Users/yukai/Projects/Personal/tsm/src/lib/panel.sh`
- `/Users/yukai/Projects/Personal/tsm/src/lib/help.sh`
- `/Users/yukai/Projects/Personal/tsm/src/lib/main.sh`

`/Users/yukai/Projects/Personal/tsm/scripts/build.sh` assembles these modules into the single-file distributable at `/Users/yukai/Projects/Personal/tsm/tsm`.

### Commands

```bash
make build
make lint
make test-integration
make test
```

## Integration test strategy

Tests are tmux-driven, black-box, and isolated per run.

- Each scenario uses a unique tmux socket (`-L <name>`) and explicit config (`-f fixtures/tmux.test.conf`)
- Tests create detached sessions, run panel/workflow actions, assert via tmux formats, and tear down the tmux server
- Panel commands are triggered with `tmux run-shell "env TMUX_PANE=<pane> tsm panel toggle ..."`

Current coverage in `/Users/yukai/Projects/Personal/tsm/tests/integration`:

- smoke/config parse
- panel open/close/reopen lifecycle
- panel PID persistence across windows
- stale metadata safety (no unrelated pane kill)
- focus behavior (open focuses panel, close restores previous pane)
- complex layout full-width bottom panel placement

## Release and distribution

### 1. Create release artifacts

```bash
make release-dist VERSION=v0.1.0
```

This creates:

- `/Users/yukai/Projects/Personal/tsm/dist/tsm-v0.1.0.tar.gz`
- `/Users/yukai/Projects/Personal/tsm/dist/tsm-v0.1.0.tar.gz.sha256`

### 2. Publish Git tag

```bash
git tag v0.1.0
git push origin v0.1.0
```

`/Users/yukai/Projects/Personal/tsm/.github/workflows/release.yml` publishes those files to GitHub Releases.

### 3. Homebrew tap PR automation

`/Users/yukai/Projects/Personal/tsm/.github/workflows/release.yml` now includes a `homebrew-pr` job that:

- rebuilds release artifacts for the tag
- regenerates `Formula/tsm.rb`
- opens/updates a PR in `Yukaii/homebrew-tap`

One-time setup:

- add repository secret `HOMEBREW_TAP_DEPLOY_KEY` in `Yukaii/tsm`
- use a write-enabled deploy key attached to `Yukaii/homebrew-tap` (SSH private key in the secret)
- workflow uses `GITHUB_TOKEN` (`github.token`) with permissions for `contents`, `pull-requests`, and `issues`

If `HOMEBREW_TAP_DEPLOY_KEY` is missing, release publishing still works, and only the tap PR job is skipped.

Note: `GITHUB_TOKEN` permissions are scoped by GitHub settings. If cross-repo PR API access to
`Yukaii/homebrew-tap` is blocked for `Yukaii/tsm` workflows, you still need a dedicated token or
GitHub App token for PR creation.

Manual fallback:

```bash
SHA=$(cut -d' ' -f1 dist/tsm-v0.1.0.tar.gz.sha256)
./scripts/generate-homebrew-formula.sh v0.1.0 "$SHA"
```

## Requirements

- bash
- tmux
- git (for worktree commands)
- fzf/fzf-tmux (for interactive worktree selection)

## License

MIT

#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=tests/integration/lib.sh
source "${TEST_DIR}/lib.sh"

setup_tmux

p2=$(tmuxc split-window -d -h -P -F '#{pane_id}' -t "$MAIN_PANE")
tmuxc split-window -d -v -P -F '#{pane_id}' -t "$p2" >/dev/null

run_panel_toggle "$MAIN_PANE" "--direction bottom"

panel_id=$(window_opt "$MAIN_PANE" @tsm_panel_id)
panel_width=$(tmuxc display-message -p -t "$panel_id" '#{pane_width}')
window_width=$(tmuxc display-message -p -t "$panel_id" '#{window_width}')
assert_eq "$window_width" "$panel_width" "bottom panel should span full window width"

log "PASS: full-width panel"

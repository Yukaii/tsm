#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=tests/integration/lib.sh
source "${TEST_DIR}/lib.sh"

setup_tmux

run_panel_toggle "$MAIN_PANE"
panel_id=$(window_opt "$MAIN_PANE" @tsm_panel_id)
selected_on_open=$(tmuxc display-message -p -t test:1.1 '#{pane_id}')
assert_eq "$panel_id" "$selected_on_open" "opening panel should focus panel"

run_panel_toggle "$panel_id"
selected_after_close=$(tmuxc display-message -p -t test:1.1 '#{pane_id}')
assert_eq "$MAIN_PANE" "$selected_after_close" "closing panel from panel should return focus"

log "PASS: panel focus"

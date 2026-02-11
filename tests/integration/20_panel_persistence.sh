#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=tests/integration/lib.sh
source "${TEST_DIR}/lib.sh"

setup_tmux

run_panel_toggle "$MAIN_PANE"
panel_id=$(window_opt "$MAIN_PANE" @tsm_panel_id)
orig_pid=$(window_opt "$MAIN_PANE" @tsm_panel_pid)
assert_non_empty "$panel_id" "panel should open"
assert_non_empty "$orig_pid" "panel pid should exist"

run_panel_toggle "$panel_id"

second_window_pane=$(tmuxc new-window -P -F '#{pane_id}' -t test: -n second)
run_panel_toggle "$second_window_pane"
new_pid=$(window_opt "$second_window_pane" @tsm_panel_pid)
assert_eq "$orig_pid" "$new_pid" "panel PID should persist after hide/show across windows"

log "PASS: panel persistence"

#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=tests/integration/lib.sh
source "${TEST_DIR}/lib.sh"

setup_tmux

window_id=$(tmuxc display-message -p -t "$MAIN_PANE" '#{window_id}')
victim_pane=$(tmuxc split-window -d -h -P -F '#{pane_id}' -t "$MAIN_PANE")
count_before=$(tmuxc list-panes -t "$window_id" -F '#{pane_id}' | wc -l | tr -d ' ')

tmuxc set-window-option -t "$window_id" @tsm_panel_id "$victim_pane"
tmuxc set-window-option -t "$window_id" @tsm_panel_pid "999999"
tmuxc set-window-option -t "$window_id" @tsm_panel_sig "v6"
tmuxc set-window-option -t "$window_id" @tsm_panel_return_pane "$MAIN_PANE"

run_panel_toggle "$MAIN_PANE"

count_after=$(tmuxc list-panes -t "$window_id" -F '#{pane_id}' | wc -l | tr -d ' ')
expected_count=$((count_before + 1))
assert_eq "$expected_count" "$count_after" "stale metadata should not kill unrelated panes"
pane_exists_in_window "$victim_pane" "$window_id" || fail "victim pane should still exist"

log "PASS: stale metadata safety"

#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=tests/integration/lib.sh
source "${TEST_DIR}/lib.sh"

setup_tmux

run_panel_toggle "$MAIN_PANE"
panel_id=$(window_opt "$MAIN_PANE" @tsm_panel_id)
panel_pid=$(window_opt "$MAIN_PANE" @tsm_panel_pid)
assert_non_empty "$panel_id" "panel id should be tracked after opening"
assert_non_empty "$panel_pid" "panel pid should be tracked after opening"

run_panel_toggle "$panel_id"
closed_id=$(window_opt "$MAIN_PANE" @tsm_panel_id)
parked_id=$(session_opt test @tsm_panel_parked_id)
assert_eq "" "$closed_id" "panel metadata should be cleared after closing"
assert_non_empty "$parked_id" "panel should be parked after closing"

run_panel_toggle "$MAIN_PANE"
reopened_id=$(window_opt "$MAIN_PANE" @tsm_panel_id)
assert_non_empty "$reopened_id" "panel should reopen"

log "PASS: panel lifecycle"

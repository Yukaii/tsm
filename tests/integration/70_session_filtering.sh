#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=tests/integration/lib.sh
source "${TEST_DIR}/lib.sh"

setup_tmux

# Create sessions that should be hidden from `tsm list`.
tmuxc new-session -d -s __tsm_panel_store_hidden -c "$REPO_ROOT"
tmuxc new-session -d -s popout_hidden -c "$REPO_ROOT"

# Create regular and floating sessions that should remain visible.
tmuxc new-session -d -s alpha -c "$REPO_ROOT"
tmuxc new-session -d -s floating_beta_1 -c "$REPO_ROOT"

out_file=$(mktemp)
done_key="tsm_list_done_${RANDOM}_${RANDOM}"
tmuxc run-shell -t "$MAIN_PANE" "'$TSM_TEST_BIN' list > '$out_file'; tmux wait-for -S '$done_key'"
tmuxc wait-for "$done_key"

output=$(cat "$out_file")
printf '%s\n' "$output" | grep -qx "alpha" || fail "regular session should be listed"
printf '%s\n' "$output" | grep -qx "beta" || fail "floating session base name should be listed"

if printf '%s\n' "$output" | grep -q "__tsm_panel_store_hidden"; then
    fail "internal panel store session must be filtered from list"
fi
if printf '%s\n' "$output" | grep -q "popout_hidden"; then
    fail "popout session must be filtered from list"
fi

log "PASS: session filtering"

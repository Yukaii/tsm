#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${TEST_DIR}/../.." && pwd)

TSM_TEST_BIN=${TSM_TEST_BIN:-"${REPO_ROOT}/tsm"}
TSM_TEST_TMUX_CONF=${TSM_TEST_TMUX_CONF:-"${REPO_ROOT}/fixtures/tmux.test.conf"}
TSM_TEST_SOCKET="tsm_test_${$}_$(date +%s)_${RANDOM}"

log() {
    printf '%s\n' "$*"
}

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

assert_eq() {
    local expected="$1"
    local actual="$2"
    local msg="$3"
    if [ "$expected" != "$actual" ]; then
        fail "${msg} (expected='${expected}' actual='${actual}')"
    fi
}

assert_non_empty() {
    local value="$1"
    local msg="$2"
    if [ -z "$value" ]; then
        fail "$msg"
    fi
}

tmuxc() {
    tmux -L "$TSM_TEST_SOCKET" -f "$TSM_TEST_TMUX_CONF" "$@"
}

cleanup_tmux() {
    tmuxc kill-server >/dev/null 2>&1 || true
}

setup_tmux() {
    command -v tmux >/dev/null 2>&1 || fail "tmux is required"
    [ -x "$TSM_TEST_BIN" ] || fail "tsm binary not executable at $TSM_TEST_BIN"
    [ -f "$TSM_TEST_TMUX_CONF" ] || fail "tmux test config missing at $TSM_TEST_TMUX_CONF"

    trap cleanup_tmux EXIT

    tmuxc start-server
    tmuxc new-session -d -s test -x 180 -y 50
    MAIN_PANE=$(tmuxc display-message -p -t test:1.1 '#{pane_id}')
    export MAIN_PANE
}

run_panel_toggle() {
    local pane="$1"
    shift || true

    local done_key="tsm_done_${RANDOM}_${RANDOM}"
    local args="$*"
    tmuxc run-shell -t "$pane" "env TMUX_PANE=$pane '$TSM_TEST_BIN' panel toggle $args; tmux wait-for -S '$done_key'"
    tmuxc wait-for "$done_key"
}

window_opt() {
    local pane="$1"
    local opt="$2"
    tmuxc show-window-options -v -t "$pane" "$opt" 2>/dev/null || true
}

session_opt() {
    local session="$1"
    local opt="$2"
    tmuxc show-options -v -t "$session" "$opt" 2>/dev/null || true
}

pane_exists_in_window() {
    local pane="$1"
    local window="$2"
    tmuxc list-panes -t "$window" -F '#{pane_id}' | grep -qx "$pane"
}

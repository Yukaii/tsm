#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=tests/integration/lib.sh
source "${TEST_DIR}/lib.sh"

# shellcheck source=src/lib/sessions.sh
source "${REPO_ROOT}/src/lib/sessions.sh"

socket="/tmp/tmux-501/custom.sock"
session="floating_test_0"
cmd=$(popup_build_attach_cmd "$socket" "$session")

printf '%s' "$cmd" | grep -Fq -- "TMUX= tmux -S \\\"/tmp/tmux-501/custom.sock\\\" attach -t \\\"floating_test_0\\\"" \
    || fail "popup attach command should preserve socket and attach to the floating session"

cmd_with_switch=$(popup_build_attach_cmd "$socket" "$session" "tmux select-window -t 2 ;")
printf '%s' "$cmd_with_switch" | grep -Fq -- "tmux select-window -t 2 ;" \
    || fail "popup attach command should include switch command when provided"

log "PASS: popup socket attach command"

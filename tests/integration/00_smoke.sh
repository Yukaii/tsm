#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd "$(dirname "$0")" && pwd)
# shellcheck source=tests/integration/lib.sh
source "${TEST_DIR}/lib.sh"

bash -n "$TSM_TEST_BIN"
setup_tmux

tmuxc new-window -t test: -n smoke >/dev/null
tmuxc list-sessions >/dev/null

log "PASS: smoke"

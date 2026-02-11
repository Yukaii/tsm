#!/usr/bin/env bash
set -euo pipefail

TEST_DIR=$(cd "$(dirname "$0")" && pwd)

status=0
for test_file in "$TEST_DIR"/[0-9][0-9]_*.sh; do
    echo "==> $(basename "$test_file")"
    if ! "$test_file"; then
        status=1
    fi
done

exit "$status"

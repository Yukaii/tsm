#!/usr/bin/env bash
set -euo pipefail

FORMULA_PATH="${1:-}"
VERSION="${2:-}"
SHA256="${3:-}"

if [ -z "$FORMULA_PATH" ] || [ -z "$VERSION" ] || [ -z "$SHA256" ]; then
  echo "Usage: scripts/update-homebrew-formula.sh <formula-path> <version> <sha256>" >&2
  exit 1
fi

if [ ! -f "$FORMULA_PATH" ]; then
  echo "Formula not found: $FORMULA_PATH" >&2
  exit 1
fi

URL="https://github.com/Yukaii/tsm/releases/download/${VERSION}/tsm-${VERSION}.tar.gz"

sed -i.bak \
  -e "s#^  url \".*\"#  url \"${URL}\"#" \
  -e "s#^  sha256 \".*\"#  sha256 \"${SHA256}\"#" \
  -e '/^    system "bash", "\.\/scripts\/build\.sh", "\.\/tsm"$/d' \
  "$FORMULA_PATH"

rm -f "${FORMULA_PATH}.bak"

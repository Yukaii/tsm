#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
VERSION="${1:-}"
SHA256="${2:-}"

if [ -z "$VERSION" ] || [ -z "$SHA256" ]; then
  echo "Usage: scripts/generate-homebrew-formula.sh <version> <sha256>" >&2
  exit 1
fi

sed \
  -e "s#__VERSION__#${VERSION}#g" \
  -e "s#__SHA256__#${SHA256}#g" \
  "${ROOT_DIR}/packaging/homebrew/tsm.rb.template"

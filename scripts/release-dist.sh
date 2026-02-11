#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DIST_DIR="${ROOT_DIR}/dist"
VERSION="${1:-}"

if [ -z "$VERSION" ]; then
  echo "Usage: scripts/release-dist.sh <version>" >&2
  exit 1
fi

"${ROOT_DIR}/scripts/build.sh" "${ROOT_DIR}/tsm"

mkdir -p "$DIST_DIR"
cp "${ROOT_DIR}/tsm" "${DIST_DIR}/tsm"
tar -C "$DIST_DIR" -czf "${DIST_DIR}/tsm-${VERSION}.tar.gz" tsm

if command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "${DIST_DIR}/tsm-${VERSION}.tar.gz" > "${DIST_DIR}/tsm-${VERSION}.tar.gz.sha256"
else
  sha256sum "${DIST_DIR}/tsm-${VERSION}.tar.gz" > "${DIST_DIR}/tsm-${VERSION}.tar.gz.sha256"
fi

echo "Created: ${DIST_DIR}/tsm-${VERSION}.tar.gz"
echo "Created: ${DIST_DIR}/tsm-${VERSION}.tar.gz.sha256"

#!/usr/bin/env bash
set -euo pipefail

OUT="plugins/inventory/yacloud_compute.py"
URL="https://raw.githubusercontent.com/rodion-goritskov/yacloud_compute/master/yacloud_compute.py"

echo "Downloading yacloud_compute plugin to $OUT"
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$URL" -o "$OUT"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$OUT" "$URL"
else
  echo "Error: curl or wget required to download plugin" >&2
  exit 2
fi
chmod +x "$OUT"
echo "Downloaded and made executable: $OUT"

#!/usr/bin/env bash
set -Eeuo pipefail
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
rm -rf "$PROJECT_ROOT/run/case" "$PROJECT_ROOT/results"
echo "[OK] Generated working data removed."


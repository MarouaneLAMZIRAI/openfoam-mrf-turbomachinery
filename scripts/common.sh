#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OPENFOAM_BASHRC="/opt/openfoam14/etc/bashrc"

die() {
  printf '[ERROR] %s\n' "$*" >&2
  exit 1
}

info() {
  printf '[INFO] %s\n' "$*"
}

load_openfoam() {
  [[ -f "$OPENFOAM_BASHRC" ]] || die "OpenFOAM 14 not found. Run setup.bat first."
  set +u
  # shellcheck disable=SC1090
  source "$OPENFOAM_BASHRC"
  set -u
  command -v blockMesh >/dev/null || die "blockMesh is unavailable after sourcing OpenFOAM."
}

load_config() {
  local cfg="$PROJECT_ROOT/config/simulation.env"
  [[ -f "$cfg" ]] || die "Missing $cfg"
  set -a
  # shellcheck disable=SC1090
  source "$cfg"
  set +a
  [[ "${RPM:-}" =~ ^[0-9]+([.][0-9]+)?$ ]] || die "RPM must be a positive number."
  python3 -c 'import sys; raise SystemExit(0 if float(sys.argv[1]) > 0 else 1)' "$RPM" || die "RPM must be greater than zero."
  [[ "${RECREATE_CASE:-0}" =~ ^[01]$ ]] || die "RECREATE_CASE must be 0 or 1."
}

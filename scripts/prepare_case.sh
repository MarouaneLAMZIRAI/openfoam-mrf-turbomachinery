#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"
load_openfoam
load_config

CASE_DIR="$PROJECT_ROOT/run/case"
if [[ "${RECREATE_CASE:-0}" == "1" ]]; then
  rm -rf "$CASE_DIR"
fi

if [[ -d "$CASE_DIR" && -f "$CASE_DIR/.configured_rpm" ]]; then
  previous_rpm="$(<"$CASE_DIR/.configured_rpm")"
  if ! python3 -c 'import sys; raise SystemExit(0 if abs(float(sys.argv[1]) - float(sys.argv[2])) < 1e-12 else 1)' "$previous_rpm" "$RPM"; then
    info "RPM changed from $previous_rpm to $RPM; recreating the case to avoid reusing an old solution."
    rm -rf "$CASE_DIR"
  fi
fi

if [[ ! -d "$CASE_DIR" ]]; then
  tutorial="$(bash "$PROJECT_ROOT/scripts/find_tutorial.sh")"
  info "Copying version-matched official tutorial: $tutorial"
  mkdir -p "$(dirname "$CASE_DIR")"
  cp -a "$tutorial" "$CASE_DIR"
fi

omega="$(python3 -c "import math; print(float('$RPM')*2*math.pi/60)")"
python3 "$PROJECT_ROOT/tools/set_rotation_speed.py" --case "$CASE_DIR" --omega "$omega" --rpm "$RPM"
printf '%s\n' "$RPM" > "$CASE_DIR/.configured_rpm"
info "Prepared case at $CASE_DIR for $RPM rpm ($omega rad/s)."

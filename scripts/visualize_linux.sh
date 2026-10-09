#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"
load_openfoam

CASE_DIR="$PROJECT_ROOT/run/case"
[[ -d "$CASE_DIR" ]] || die "No generated case found. Run the simulation first."
command -v paraFoam >/dev/null 2>&1 || die "paraFoam is unavailable. Rerun setup."

if [[ "${MRF_SOFTWARE_RENDERING:-0}" == "1" ]]; then
  export LIBGL_ALWAYS_SOFTWARE=1
  info "ParaView software rendering is enabled."
fi

cd "$CASE_DIR"
touch case.OpenFOAM
info "Launching ParaView. Select the latest time and click Apply."
paraFoam

#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"
load_openfoam

CASE_DIR="$PROJECT_ROOT/run/case"
[[ -d "$CASE_DIR" ]] || die "No generated case found. Run the simulation first."
mkdir -p "$PROJECT_ROOT/results/logs"
cd "$CASE_DIR"

info "Calculating vorticity at the latest time..."
postProcess -func vorticity -latestTime 2>&1 | tee "$PROJECT_ROOT/results/logs/postProcess-vorticity.log"

info "Calculating Q criterion at the latest time..."
postProcess -func Q -latestTime 2>&1 | tee "$PROJECT_ROOT/results/logs/postProcess-Q.log"

info "Post-processing fields are ready for ParaView."

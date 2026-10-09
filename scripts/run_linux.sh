#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"
load_openfoam
load_config

mkdir -p "$PROJECT_ROOT/results/logs" "$PROJECT_ROOT/results/report" "$PROJECT_ROOT/results/prediction"
bash "$PROJECT_ROOT/scripts/prepare_case.sh"
CASE_DIR="$PROJECT_ROOT/run/case"
cd "$CASE_DIR"

info "Running mesh and solver at $RPM rpm..."
[[ -f ./Allrun ]] || die "The copied official tutorial does not contain Allrun."
bash ./Allrun 2>&1 | tee "$PROJECT_ROOT/results/logs/Allrun.log"

# Official Allrun scripts normally redirect detailed application output to
# case-level log.* files. Copy them into the auditable results folder.
while IFS= read -r -d '' log_file; do
  cp -f "$log_file" "$PROJECT_ROOT/results/logs/"
done < <(find "$CASE_DIR" -maxdepth 1 -type f -name 'log.*' -print0)

checkMesh -latestTime 2>&1 | tee "$PROJECT_ROOT/results/logs/checkMesh-final.log"
python3 "$PROJECT_ROOT/tools/summarize_run.py" \
  --case "$CASE_DIR" \
  --rpm "$RPM" \
  --logs "$PROJECT_ROOT/results/logs" \
  --output "$PROJECT_ROOT/results/report/run_summary.json"

"$PROJECT_ROOT/.venv/bin/python" "$PROJECT_ROOT/predictor/affinity_predictor.py" \
  --rpm "$RPM" \
  --output "$PROJECT_ROOT/results/prediction/affinity_prediction.csv"

info "Finished. Open $CASE_DIR in ParaView with: paraFoam"

#!/usr/bin/env bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"

required=(
  README.md
  LICENSE
  requirements.txt
  config/simulation.env
  config/reference_operating_point.json
  predictor/affinity_predictor.py
  predictor/train_surrogate.py
  tools/set_rotation_speed.py
  tools/summarize_run.py
  scripts/postprocess_linux.sh
  scripts/visualize_linux.sh
)
for item in "${required[@]}"; do
  [[ -e "$PROJECT_ROOT/$item" ]] || die "Missing project file: $item"
done

python3 -m json.tool "$PROJECT_ROOT/config/reference_operating_point.json" >/dev/null
python3 -m compileall -q "$PROJECT_ROOT/predictor" "$PROJECT_ROOT/tools" "$PROJECT_ROOT/tests"
python3 -m unittest discover -s "$PROJECT_ROOT/tests" -v
for script in "$PROJECT_ROOT"/scripts/*.sh; do
  bash -n "$script"
done

if [[ -f "$OPENFOAM_BASHRC" ]]; then
  load_openfoam
  command -v foamRun >/dev/null || die "foamRun is unavailable."
  command -v paraFoam >/dev/null || die "paraFoam is unavailable."
  tutorial="$(bash "$PROJECT_ROOT/scripts/find_tutorial.sh")"
  info "OpenFOAM tutorial found: $tutorial"
else
  die "OpenFOAM 14 is not installed. Run setup.bat."
fi

[[ -x "$PROJECT_ROOT/.venv/bin/python" ]] || die "Python environment missing. Run setup.bat."
"$PROJECT_ROOT/.venv/bin/python" -c "import numpy"
python3 "$PROJECT_ROOT/predictor/affinity_predictor.py" --rpm 600 >/dev/null
info "All verification checks passed."

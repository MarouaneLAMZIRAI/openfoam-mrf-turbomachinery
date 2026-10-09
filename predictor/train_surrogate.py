#!/usr/bin/env python3
"""Fit a small quadratic surrogate to real CFD/experimental sweep data."""

from __future__ import annotations

import argparse
import csv
import json
from pathlib import Path

import numpy as np


TARGETS = ("pressure_rise_pa", "torque_nm", "power_w")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--data", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    with args.data.open(newline="", encoding="utf-8") as stream:
        rows = list(csv.DictReader(stream))
    if len(rows) < 6:
        raise SystemExit("At least six real observations are required; synthetic filling is disabled.")
    required = {"rpm", "flow_rate_m3_s", *TARGETS}
    missing = required.difference(rows[0])
    if missing:
        raise SystemExit(f"Missing CSV columns: {', '.join(sorted(missing))}")
    rpm = np.array([float(row["rpm"]) for row in rows])
    flow = np.array([float(row["flow_rate_m3_s"]) for row in rows])
    r_scale = max(np.max(np.abs(rpm)), 1.0)
    q_scale = max(np.max(np.abs(flow)), 1e-12)
    r = rpm / r_scale
    q = flow / q_scale
    design = np.column_stack([np.ones_like(r), r, q, r * r, r * q, q * q])
    model = {
        "classification": "data_fitted_quadratic_surrogate",
        "training_rows": len(rows),
        "features": ["1", "rpm", "flow", "rpm^2", "rpm*flow", "flow^2"],
        "scales": {"rpm": r_scale, "flow_rate_m3_s": q_scale},
        "targets": {},
    }
    for target in TARGETS:
        values = np.array([float(row[target]) for row in rows])
        coefficients, *_ = np.linalg.lstsq(design, values, rcond=None)
        fitted = design @ coefficients
        ss_res = float(np.sum((values - fitted) ** 2))
        ss_tot = float(np.sum((values - values.mean()) ** 2))
        r2 = 1.0 - ss_res / ss_tot if ss_tot > 0 else 1.0
        model["targets"][target] = {"coefficients": coefficients.tolist(), "training_r2": r2}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(model, indent=2) + "\n", encoding="utf-8")
    print(args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


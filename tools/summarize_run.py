#!/usr/bin/env python3
"""Create a small, auditable summary without claiming validation."""

from __future__ import annotations

import argparse
import json
import re
from datetime import datetime, timezone
from pathlib import Path

FLOAT_PATTERN = r"[-+]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?"


def latest_time(case: Path) -> str | None:
    values = []
    for path in case.iterdir():
        if path.is_dir():
            try:
                values.append((float(path.name), path.name))
            except ValueError:
                pass
    return max(values)[1] if values else None


def scan_logs(log_dir: Path) -> dict[str, object]:
    converged_markers = 0
    fatal: list[str] = []
    final_residuals: dict[str, float] = {}
    power_numbers: list[float] = []
    mesh_metrics: dict[str, object] = {}
    residual_re = re.compile(
        rf"Solving for\s+(\w+).*Final residual =\s*({FLOAT_PATTERN})"
    )
    power_re = re.compile(rf"Power number\s*=\s*({FLOAT_PATTERN})", re.IGNORECASE)
    metric_patterns = {
        "cells": re.compile(r"(?m)^\s*cells:\s+(\d+)"),
        "max_aspect_ratio": re.compile(
            rf"Max aspect ratio\s*=\s*({FLOAT_PATTERN})", re.IGNORECASE
        ),
        "max_non_orthogonality_deg": re.compile(
            rf"Mesh non-orthogonality Max:\s*({FLOAT_PATTERN})", re.IGNORECASE
        ),
        "max_skewness": re.compile(
            rf"Max skewness\s*=\s*({FLOAT_PATTERN})", re.IGNORECASE
        ),
    }
    for path in sorted(log_dir.iterdir()):
        if not path.is_file():
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        converged_markers += len(re.findall(r"(?m)^End\s*$", text))
        if "FOAM FATAL" in text or "Segmentation fault" in text:
            fatal.append(path.name)
        for field, value in residual_re.findall(text):
            try:
                final_residuals[field] = float(value)
            except ValueError:
                pass
        power_numbers.extend(float(value) for value in power_re.findall(text))
        for name, pattern in metric_patterns.items():
            match = pattern.search(text)
            if match:
                mesh_metrics[name] = (
                    int(match.group(1)) if name == "cells" else float(match.group(1))
                )
        if "Mesh OK." in text:
            mesh_metrics["status"] = "Mesh OK"
    return {
        "end_markers": converged_markers,
        "fatal_logs": fatal,
        "last_reported_final_residuals": final_residuals,
        "last_reported_power_number": power_numbers[-1] if power_numbers else None,
        "mesh": mesh_metrics,
    }


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", type=Path, required=True)
    parser.add_argument("--rpm", type=float, required=True)
    parser.add_argument("--logs", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    log_checks = scan_logs(args.logs)
    payload = {
        "classification": "educational_numerical_simulation_not_validated",
        "execution_status": (
            "completed_without_fatal_log_marker"
            if not log_checks["fatal_logs"]
            else "fatal_log_marker_detected"
        ),
        "model": "MRF_from_version_matched_official_OpenFOAM_rotating_impeller_tutorial",
        "rpm": args.rpm,
        "latest_time_directory": latest_time(args.case),
        "generated_utc": datetime.now(timezone.utc).isoformat(),
        "log_checks": log_checks,
        "limitations": [
            "No mesh-independence study is included in the default run.",
            "No experimental validation is claimed.",
            "MRF does not resolve transient blade-passing interactions.",
        ],
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    print(args.output)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

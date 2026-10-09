#!/usr/bin/env python3
"""Physics-informed prediction using turbomachinery affinity laws."""

from __future__ import annotations

import argparse
import csv
import json
import math
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_REFERENCE = ROOT / "config" / "reference_operating_point.json"


def load_reference(path: Path) -> dict[str, float | str]:
    data = json.loads(path.read_text(encoding="utf-8"))
    required = (
        "reference_rpm",
        "flow_rate_m3_s",
        "pressure_rise_pa",
        "torque_nm",
        "power_w",
    )
    missing = [key for key in required if key not in data]
    if missing:
        raise ValueError(f"Missing reference keys: {', '.join(missing)}")
    if float(data["reference_rpm"]) <= 0:
        raise ValueError("reference_rpm must be positive")
    return data


def predict(reference: dict[str, float | str], rpm: float) -> dict[str, float | str]:
    if rpm <= 0:
        raise ValueError("rpm must be positive")
    ratio = rpm / float(reference["reference_rpm"])
    torque = float(reference["torque_nm"]) * ratio**2
    power_from_torque = torque * rpm * 2.0 * math.pi / 60.0
    return {
        "status": str(reference.get("status", "unspecified")),
        "rpm": rpm,
        "speed_ratio": ratio,
        "flow_rate_m3_s": float(reference["flow_rate_m3_s"]) * ratio,
        "pressure_rise_pa": float(reference["pressure_rise_pa"]) * ratio**2,
        "torque_nm": torque,
        "power_w_affinity": float(reference["power_w"]) * ratio**3,
        "power_w_from_torque": power_from_torque,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reference", type=Path, default=DEFAULT_REFERENCE)
    parser.add_argument("--rpm", nargs="+", type=float, required=True)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    reference = load_reference(args.reference)
    rows = [predict(reference, rpm) for rpm in args.rpm]
    fieldnames = list(rows[0])
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        with args.output.open("w", newline="", encoding="utf-8") as stream:
            writer = csv.DictWriter(stream, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(rows)
        print(args.output)
    else:
        writer = csv.DictWriter(__import__("sys").stdout, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())


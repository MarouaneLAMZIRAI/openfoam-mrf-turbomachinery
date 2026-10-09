#!/usr/bin/env python3
"""Update a copied OpenFOAM MRF tutorial with a requested angular speed."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


OMEGA_PATTERNS = (
    re.compile(r"(?m)^(\s*omega\s+)([-+0-9.eE]+)(\s*(?:\[[^\]]+\])?\s*;)") ,
    re.compile(r"(?m)^(\s*angularVelocity\s+)([-+0-9.eE]+)(\s*(?:\[[^\]]+\])?\s*;)") ,
)


def update_file(path: Path, omega: float) -> bool:
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return False
    changed = False
    for pattern in OMEGA_PATTERNS:
        def replacement(match: re.Match[str]) -> str:
            suffix = match.group(3)
            # Newer Foundation tutorials express omega in rpm. Preserve that
            # dimensional unit and convert the supplied rad/s value back.
            value = omega
            if "[rpm]" in suffix.replace(" ", ""):
                value = omega * 60.0 / (2.0 * 3.141592653589793)
            return f"{match.group(1)}{value:.12g}{suffix}"

        text, count = pattern.subn(replacement, text)
        changed = changed or count > 0
    if changed:
        path.write_text(text, encoding="utf-8")
    return changed


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", type=Path, required=True)
    parser.add_argument("--omega", type=float, required=True)
    parser.add_argument("--rpm", type=float, required=True)
    args = parser.parse_args()
    if args.omega <= 0 or args.rpm <= 0:
        parser.error("omega and rpm must be positive")

    search_roots = [args.case / "constant", args.case / "system"]
    changed = []
    for root in search_roots:
        if not root.exists():
            continue
        for path in root.rglob("*"):
            if path.is_file() and update_file(path, args.omega):
                changed.append(path)

    if not changed:
        raise SystemExit(
            "No omega/angularVelocity entry was found. The installed tutorial "
            "is incompatible with this parameterizer; no case was run."
        )

    manifest = args.case / "rotation_configuration.txt"
    manifest.write_text(
        f"rpm={args.rpm:.12g}\nomega_rad_s={args.omega:.12g}\n"
        + "updated_files=\n"
        + "\n".join(str(p.relative_to(args.case)) for p in changed)
        + "\n",
        encoding="utf-8",
    )
    print(f"Updated {len(changed)} file(s) for {args.rpm:g} rpm")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

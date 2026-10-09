from __future__ import annotations

import importlib.util
import math
import tempfile
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).resolve().parents[1] / "tools" / "set_rotation_speed.py"
SPEC = importlib.util.spec_from_file_location("set_rotation_speed", MODULE_PATH)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class RotationSpeedTests(unittest.TestCase):
    def test_dimensionless_rad_per_second_entry(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "MRFProperties"
            path.write_text("omega 5;\n", encoding="utf-8")
            self.assertTrue(MODULE.update_file(path, 2.5))
            self.assertEqual(path.read_text(encoding="utf-8"), "omega 2.5;\n")

    def test_rpm_dimension_is_preserved(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "rotatingZoneProperties"
            path.write_text("omega 5 [rpm];\n", encoding="utf-8")
            omega = 600.0 * 2.0 * math.pi / 60.0
            self.assertTrue(MODULE.update_file(path, omega))
            self.assertEqual(path.read_text(encoding="utf-8"), "omega 600 [rpm];\n")


if __name__ == "__main__":
    unittest.main()

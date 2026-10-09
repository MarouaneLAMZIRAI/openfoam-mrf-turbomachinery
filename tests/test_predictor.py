from __future__ import annotations

import json
import math
import tempfile
import unittest
from pathlib import Path

from predictor.affinity_predictor import load_reference, predict


class AffinityPredictorTests(unittest.TestCase):
    def setUp(self) -> None:
        self.reference = {
            "status": "test",
            "reference_rpm": 1000.0,
            "flow_rate_m3_s": 1.0,
            "pressure_rise_pa": 100.0,
            "torque_nm": 2.0,
            "power_w": 200.0,
        }

    def test_reference_point_is_preserved(self) -> None:
        result = predict(self.reference, 1000.0)
        self.assertAlmostEqual(result["flow_rate_m3_s"], 1.0)
        self.assertAlmostEqual(result["pressure_rise_pa"], 100.0)
        self.assertAlmostEqual(result["torque_nm"], 2.0)
        self.assertAlmostEqual(result["power_w_affinity"], 200.0)

    def test_double_speed_obeys_affinity_laws(self) -> None:
        result = predict(self.reference, 2000.0)
        self.assertAlmostEqual(result["flow_rate_m3_s"], 2.0)
        self.assertAlmostEqual(result["pressure_rise_pa"], 400.0)
        self.assertAlmostEqual(result["torque_nm"], 8.0)
        self.assertAlmostEqual(result["power_w_affinity"], 1600.0)

    def test_power_from_torque_is_dimensionally_consistent(self) -> None:
        result = predict(self.reference, 1000.0)
        self.assertAlmostEqual(result["power_w_from_torque"], 2 * 1000 * 2 * math.pi / 60)

    def test_nonpositive_speed_is_rejected(self) -> None:
        with self.assertRaises(ValueError):
            predict(self.reference, 0)

    def test_reference_validation(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "bad.json"
            path.write_text(json.dumps({"reference_rpm": 100}), encoding="utf-8")
            with self.assertRaises(ValueError):
                load_reference(path)


if __name__ == "__main__":
    unittest.main()


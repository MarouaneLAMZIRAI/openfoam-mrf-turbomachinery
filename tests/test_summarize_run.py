from __future__ import annotations

import importlib.util
import tempfile
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).resolve().parents[1] / "tools" / "summarize_run.py"
SPEC = importlib.util.spec_from_file_location("summarize_run", MODULE_PATH)
assert SPEC and SPEC.loader
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class RunSummaryTests(unittest.TestCase):
    def test_log_metrics_are_extracted_without_claiming_validation(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            logs = Path(directory)
            (logs / "log.foamRun").write_text(
                "Solving for Ux, Initial residual = 0.1, "
                "Final residual = 2e-06, No Iterations 2\n"
                "Power number = 2.85\nEnd\n",
                encoding="utf-8",
            )
            (logs / "checkMesh-final.log").write_text(
                "cells: 78720\n"
                "Max aspect ratio = 7.5096416 OK.\n"
                "Mesh non-orthogonality Max: 24.539314 average: 2.0\n"
                "Max skewness = 0.49106299 OK.\n"
                "Mesh OK.\nEnd\n",
                encoding="utf-8",
            )

            result = MODULE.scan_logs(logs)

            self.assertEqual(result["fatal_logs"], [])
            self.assertAlmostEqual(result["last_reported_final_residuals"]["Ux"], 2e-6)
            self.assertAlmostEqual(result["last_reported_power_number"], 2.85)
            self.assertEqual(result["mesh"]["cells"], 78720)
            self.assertEqual(result["mesh"]["status"], "Mesh OK")

    def test_fatal_log_is_reported(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            logs = Path(directory)
            (logs / "log.foamRun").write_text(
                "FOAM FATAL ERROR: example failure\n", encoding="utf-8"
            )
            result = MODULE.scan_logs(logs)
            self.assertEqual(result["fatal_logs"], ["log.foamRun"])


if __name__ == "__main__":
    unittest.main()

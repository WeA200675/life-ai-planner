import copy
import unittest

from tools.compare_scheduler_benchmarks import IncompatibleBenchmark, compare


def sample(p95=10.0):
    return {
        "schema_version": 1, "python": "3.12.0", "platform": "linux-test",
        "results": [{
            "tasks": 100, "fixed_blocks": 12, "seed": 42, "warmup": 2,
            "repeats": 7, "scheduled": 10, "deferred": 90,
            "capacity_minutes": 1440, "budget_minutes": 924,
            "median_ms": p95 / 2, "p95_ms": p95,
            "min_ms": 1.0, "max_ms": 20.0,
        }],
    }


class ComparisonTests(unittest.TestCase):
    def test_detects_regression(self):
        report = compare(sample(), sample(12.0))
        self.assertTrue(report["regression_detected"])
        self.assertEqual(report["results"][0]["change_percent"], 20.0)

    def test_improvement_is_not_regression(self):
        self.assertFalse(compare(sample(), sample(7.0))["regression_detected"])

    def test_exact_limit_allowed(self):
        self.assertFalse(compare(sample(), sample(11.0))["regression_detected"])

    def test_rejects_mismatched_environment(self):
        candidate = sample()
        candidate["platform"] = "other"
        with self.assertRaises(IncompatibleBenchmark):
            compare(sample(), candidate)

    def test_rejects_changed_workload(self):
        for field, value in (("seed", 99), ("scheduled", 11), ("fixed_blocks", 2)):
            with self.subTest(field=field):
                candidate = copy.deepcopy(sample())
                candidate["results"][0][field] = value
                with self.assertRaises(IncompatibleBenchmark):
                    compare(sample(), candidate)

    def test_rejects_duplicate_size(self):
        candidate = sample()
        candidate["results"].append(copy.deepcopy(candidate["results"][0]))
        with self.assertRaises(IncompatibleBenchmark):
            compare(sample(), candidate)

    def test_rejects_nonfinite_and_zero_baseline(self):
        for value in (float("nan"), float("inf"), -1):
            candidate = sample()
            candidate["results"][0]["p95_ms"] = value
            with self.assertRaises(IncompatibleBenchmark):
                compare(sample(), candidate)
        with self.assertRaises(IncompatibleBenchmark):
            compare(sample(0), sample())

    def test_invalid_regression_limit(self):
        with self.assertRaises(ValueError):
            compare(sample(), sample(), regression_limit=-1)


if __name__ == "__main__":
    unittest.main()

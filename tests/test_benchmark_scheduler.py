"""Correctness tests for synthetic benchmarking (no timing assertions)."""
import unittest

from tools.benchmark_scheduler import benchmark, fixture, percentile
from packages.scheduler.engine import schedule


class BenchmarkHarnessTests(unittest.TestCase):
    def test_fixture_is_deterministic(self):
        self.assertEqual(fixture(100, seed=19), fixture(100, seed=19))
        self.assertNotEqual(fixture(100, seed=19)[2], fixture(100, seed=20)[2])

    def test_fixture_has_no_overlaps(self):
        start, end, tasks, fixed = fixture(1000, fixed_count=24)
        plan = schedule(start, end, tasks, fixed)
        self.assertEqual(len(plan.deferred) + len(plan.blocks) - len(fixed), 1000)
        self.assertEqual(len({t.id for t in tasks}), 1000)

    def test_percentile_interpolates(self):
        self.assertEqual(percentile([1.0, 3.0, 5.0], .95), 4.8)
        self.assertEqual(percentile([3.0], .95), 3.0)

    def test_invalid_parameters(self):
        with self.assertRaises(ValueError):
            fixture(-1)
        with self.assertRaises(ValueError):
            fixture(1, fixed_count=97)
        with self.assertRaises(ValueError):
            percentile([], .95)
        with self.assertRaises(ValueError):
            benchmark(1, repeats=0)

    def test_benchmark_returns_measurement_metadata(self):
        data = benchmark(30, repeats=2, warmup=0, fixed_count=3)
        self.assertEqual(data["tasks"], 30)
        self.assertEqual(data["repeats"], 2)
        self.assertEqual(data["scheduled"] + data["deferred"], 30)
        self.assertGreaterEqual(data["p95_ms"], data["median_ms"])


if __name__ == "__main__":
    unittest.main()

import unittest
from datetime import date, timedelta
from packages.scheduler.calibration import DayObservation, calibrate

class CalibrationTests(unittest.TestCase):
    def observations(self, fraction, count=14):
        base = date(2026, 11, 20)
        return [DayObservation(base - timedelta(days=i), 480, int(480 * fraction), 2)
                for i in range(count)]

    def test_anchored_window_ignores_future_days(self):
        days = self.observations(0.50)
        future = DayObservation(date(2026, 12, 20), 480, 0)
        expected = calibrate(days, as_of=date(2026, 11, 20))
        self.assertEqual(calibrate(days + [future], as_of=date(2026, 11, 20)),
                         expected)

    def test_anchored_window_does_not_use_stale_days(self):
        days = self.observations(0.50)
        result = calibrate(days, as_of=date(2026, 12, 20))
        self.assertEqual(result.sample_days, 0)
        self.assertEqual(result.reason, "insufficient data")

    def test_anchored_window_is_repeatable(self):
        days = self.observations(0.50)
        day = date(2026, 11, 20)
        self.assertEqual(calibrate(days, as_of=day), calibrate(list(reversed(days)), as_of=day))

    def test_invalid_as_of_rejected(self):
        with self.assertRaises(ValueError):
            calibrate(self.observations(0.5), as_of="2026-11-20")

    def test_increase_limited_step(self):
        result = calibrate(self.observations(0.50))
        self.assertAlmostEqual(result.ratio, 0.35)
        self.assertTrue(result.changed)

    def test_decrease_limited_step(self):
        self.assertAlmostEqual(calibrate(self.observations(0.10)).ratio, 0.25)

    def test_no_change_within_tolerance(self):
        self.assertFalse(calibrate(self.observations(0.30)).changed)

    def test_insufficient_data(self):
        result = calibrate(self.observations(0.50, 6))
        self.assertEqual(result.ratio, 0.30)
        self.assertEqual(result.sample_days, 6)

    def test_duplicate_import_does_not_bias(self):
        days = self.observations(0.50)
        self.assertEqual(calibrate(days).ratio, calibrate(days + days).ratio)

    def test_conflicting_duplicate_rejected(self):
        days = self.observations(0.50)
        with self.assertRaises(ValueError):
            calibrate(days + [DayObservation(days[0].day, 480, 0)])

    def test_out_of_window_ignored(self):
        days = self.observations(0.50)
        days.append(DayObservation(date(2026, 1, 1), 480, 0))
        self.assertAlmostEqual(calibrate(days).ratio, 0.35)

    def test_invalid_observation_rejected(self):
        with self.assertRaises(ValueError):
            calibrate([DayObservation(date(2026, 11, 20), 100, 101)])

    def test_zero_capacity_not_counted(self):
        days = self.observations(0.50, 6)
        days.append(DayObservation(date(2026, 11, 21), 0, 0))
        self.assertEqual(calibrate(days).sample_days, 6)

if __name__ == "__main__":
    unittest.main()

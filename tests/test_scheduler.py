import unittest
from datetime import datetime, timedelta, timezone
from packages.scheduler import Task, Block, schedule

UTC = timezone.utc
def at(hour, minute=0):
    return datetime(2026, 11, 20, hour, minute, tzinfo=UTC)

class SchedulerTests(unittest.TestCase):
    def test_buffer_and_fixed(self):
        fixed = [Block("meeting", at(10), at(11))]
        result = schedule(at(9), at(17), [Task("a", "Work", 240), Task("b", "Extra", 60)], fixed)
        self.assertEqual(result.capacity_minutes, 480)
        self.assertEqual(result.budget_minutes, 294)
        self.assertEqual(result.deferred, ("b",))
        self.assertEqual(result.blocks[0].task_id, "a")
        self.assertEqual(result.blocks[1], fixed[0])
        self.assertEqual(result.reserved_minutes, 180)

    def test_no_overwrite_and_deadline(self):
        result = schedule(at(9), at(12), [Task("urgent", "Urgent", 90, deadline=at(10))],
                          [Block("fixed", at(9), at(10))])
        self.assertEqual(result.deferred, ("urgent",))
        self.assertEqual(result.blocks[0].task_id, "fixed")

    def test_invalid_overlap(self):
        with self.assertRaises(ValueError):
            schedule(at(9), at(12), [], [Block("a", at(9), at(11)), Block("b", at(10), at(12))])

    def test_deterministic(self):
        tasks = [Task("z", "Z", 30), Task("a", "A", 30)]
        self.assertEqual(schedule(at(9), at(12), tasks), schedule(at(9), at(12), list(reversed(tasks))))

    def test_duplicate(self):
        with self.assertRaises(ValueError):
            schedule(at(9), at(12), [Task("x", "One", 20), Task("x", "Two", 20)])

if __name__ == "__main__":
    unittest.main()

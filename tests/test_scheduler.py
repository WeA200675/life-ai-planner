import unittest
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo
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
        self.assertEqual(result.blocks[0], fixed[0])
        self.assertEqual(result.blocks[1].task_id, "a")
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


    def test_naive_deadline_rejected(self):
        with self.assertRaises(ValueError):
            schedule(at(9), at(12), [
                Task("x", "X", 30, deadline=datetime(2026, 11, 20, 10))])

    def test_dst_spring_forward_uses_elapsed_minutes(self):
        berlin = ZoneInfo("Europe/Berlin")
        start = datetime(2026, 3, 29, 1, 0, tzinfo=berlin)
        end = datetime(2026, 3, 29, 4, 0, tzinfo=berlin)
        plan = schedule(start, end, [Task("x", "X", 60)])
        self.assertEqual(plan.capacity_minutes, 120)
        self.assertEqual(plan.budget_minutes, 84)
        self.assertEqual((plan.blocks[0].end - plan.blocks[0].start).total_seconds(), 3600)

    def test_dst_fall_back_uses_elapsed_minutes(self):
        berlin = ZoneInfo("Europe/Berlin")
        start = datetime(2026, 10, 25, 1, 0, tzinfo=berlin)
        end = datetime(2026, 10, 25, 4, 0, tzinfo=berlin)
        plan = schedule(start, end, [])
        self.assertEqual(plan.capacity_minutes, 240)
        self.assertEqual(plan.budget_minutes, 168)

    def test_mixed_timezone_fixed_normalized(self):
        berlin = ZoneInfo("Europe/Berlin")
        fixed = [Block("meeting", datetime(2026, 11, 20, 10, tzinfo=berlin),
                       datetime(2026, 11, 20, 11, tzinfo=berlin))]
        plan = schedule(at(8), at(12), [Task("x", "X", 30)], fixed)
        meeting = next(b for b in plan.blocks if b.task_id == "meeting")
        self.assertEqual(meeting.start, at(9))

if __name__ == "__main__":
    unittest.main()

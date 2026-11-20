import tempfile
import unittest
from pathlib import Path
from packages.storage.plan_history import PlanHistory, RevisionConflict

def block(task, start="2026-11-20T09:00:00+01:00", end="2026-11-20T10:00:00+01:00"):
    return {"task_id": task, "start": start, "end": end}

class HistoryTests(unittest.TestCase):
    def setUp(self):
        tmp = tempfile.TemporaryDirectory()
        self.addCleanup(tmp.cleanup)
        self.history = PlanHistory(Path(tmp.name) / "history.db")

    def test_first_revision_and_persistence(self):
        rev = self.history.commit("day", [block("a")], expected_revision=0, reason="initial")
        self.assertEqual(rev.revision, 1)
        self.assertEqual(self.history.latest("day").blocks[0]["task_id"], "a")

    def test_stale_write_rejected_without_mutation(self):
        self.history.commit("day", [block("a")], expected_revision=0, reason="initial")
        with self.assertRaises(RevisionConflict):
            self.history.commit("day", [block("b")], expected_revision=0, reason="stale")
        self.assertEqual(self.history.latest("day").revision, 1)

    def test_undo_creates_new_revision(self):
        self.history.commit("day", [block("a")], expected_revision=0, reason="initial")
        self.history.commit("day", [block("b")], expected_revision=1, reason="replan")
        restored = self.history.undo("day", expected_revision=2)
        self.assertEqual(restored.revision, 3)
        self.assertEqual(restored.restored_from, 1)
        self.assertEqual(restored.blocks[0]["task_id"], "a")

    def test_undo_rejects_stale_revision(self):
        self.history.commit("day", [block("a")], expected_revision=0, reason="initial")
        self.history.commit("day", [block("b")], expected_revision=1, reason="replan")
        with self.assertRaises(RevisionConflict):
            self.history.undo("day", expected_revision=3)

    def test_overlaps_rejected(self):
        with self.assertRaises(ValueError):
            self.history.commit("day", [block("a"), block("b")],
                                expected_revision=0, reason="bad")
        self.assertIsNone(self.history.latest("day"))

    def test_bad_timezone_rejected(self):
        with self.assertRaises(ValueError):
            self.history.commit("day", [block("a", "2026-11-20T09:00:00", "2026-11-20T10:00:00")],
                                expected_revision=0, reason="bad")

    def test_separate_plans(self):
        self.history.commit("a", [block("x")], expected_revision=0, reason="init")
        self.history.commit("b", [block("y")], expected_revision=0, reason="init")
        self.assertEqual(self.history.latest("b").blocks[0]["task_id"], "y")

if __name__ == "__main__":
    unittest.main()

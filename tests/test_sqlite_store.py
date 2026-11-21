import tempfile
import unittest
from pathlib import Path
from packages.storage.sqlite_store import StoredTask, TaskStore

class TaskStoreTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.path = Path(self.tmp.name) / "planner.sqlite"
        self.store = TaskStore(self.path)

    def test_persists_after_reopen(self):
        task = StoredTask("a", "Prepare", 45, 3)
        self.store.put(task)
        self.assertEqual(TaskStore(self.path).get("a"), task)

    def test_idempotent_update(self):
        self.store.put(StoredTask("a", "Old", 20))
        self.store.put(StoredTask("a", "New", 30))
        self.assertEqual(len(self.store.list()), 1)
        self.assertEqual(self.store.get("a").title, "New")

    def test_status_and_filter(self):
        self.store.put(StoredTask("a", "A", 30))
        self.assertTrue(self.store.change_status("a", "done"))
        self.assertEqual(len(self.store.list("open")), 0)
        self.assertEqual(self.store.list("done")[0].id, "a")
        self.assertFalse(self.store.change_status("missing", "done"))

    def test_invalid_data_never_saved(self):
        with self.assertRaises(ValueError):
            self.store.put(StoredTask("x", "X", -1))
        self.assertIsNone(self.store.get("x"))

    def test_deadline_requires_timezone(self):
        with self.assertRaises(ValueError):
            self.store.put(StoredTask("x", "X", 10, deadline="2026-11-20T12:00:00"))
        self.store.put(StoredTask("x", "X", 10, deadline="2026-11-20T12:00:00+01:00"))

    def test_invalid_types_and_bounds_are_never_persisted(self):
        invalid = [
            StoredTask("x", "X", True),
            StoredTask("x", "X", "30"),
            StoredTask("x", "X", 1.5),
            StoredTask("x", "X", 1441),
            StoredTask("x", "X", 0),
            StoredTask("x", "X", 30, True),
            StoredTask("x", "X", 30, -1),
            StoredTask("x", "X", 30, 11),
            StoredTask("x", "X", 30, "2"),
            StoredTask(" x", "X", 30),
            StoredTask("x ", "X", 30),
            StoredTask(" ", "X", 30),
            StoredTask("x", " ", 30),
            StoredTask("x", "X", 30, deadline=123),
        ]
        for task in invalid:
            with self.subTest(task=task):
                with self.assertRaises(ValueError):
                    self.store.put(task)
                self.assertEqual(self.store.list(), [])

    def test_valid_boundary_values_survive_reopen(self):
        self.store.put(StoredTask("low", "Low", 1, 0))
        self.store.put(StoredTask("high", "High", 1440, 10))
        reopened = TaskStore(self.path)
        self.assertEqual(reopened.get("low").minutes, 1)
        self.assertEqual(reopened.get("high").priority, 10)

    def test_sql_injection_is_data(self):
        self.store.put(StoredTask("x'; DROP TABLE tasks;--", "safe", 10))
        self.assertEqual(len(self.store.list()), 1)

    def test_invalid_status(self):
        with self.assertRaises(ValueError):
            self.store.change_status("x", "deleted")

if __name__ == "__main__":
    unittest.main()

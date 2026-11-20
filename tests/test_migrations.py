import sqlite3
import tempfile
import unittest
from pathlib import Path
from packages.storage.migrations import migrate
from packages.storage.sqlite_store import TaskStore, StoredTask

class MigrationTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.path = Path(self.tmp.name) / "tasks.db"

    def test_new_database(self):
        store = TaskStore(self.path)
        store.put(StoredTask("a", "A", 15))
        with sqlite3.connect(self.path) as db:
            self.assertEqual(db.execute("PRAGMA user_version").fetchone()[0], 1)
        self.assertEqual(store.get("a").minutes, 15)

    def test_idempotent_existing_data(self):
        store = TaskStore(self.path)
        store.put(StoredTask("a", "Keep", 20))
        TaskStore(self.path)
        self.assertEqual(TaskStore(self.path).get("a").title, "Keep")

    def test_future_version_fails_without_downgrade(self):
        with sqlite3.connect(self.path) as db:
            db.execute("PRAGMA user_version=99")
        with self.assertRaises(RuntimeError):
            TaskStore(self.path)
        with sqlite3.connect(self.path) as db:
            self.assertEqual(db.execute("PRAGMA user_version").fetchone()[0], 99)

    def test_legacy_schema_preserves_rows(self):
        with sqlite3.connect(self.path) as db:
            db.execute("""CREATE TABLE tasks(id TEXT PRIMARY KEY,title TEXT,minutes INTEGER,
                        priority INTEGER,deadline TEXT,status TEXT)""")
            db.execute("INSERT INTO tasks VALUES('old','Legacy',10,0,NULL,'open')")
        self.assertEqual(TaskStore(self.path).get("old").title, "Legacy")

    def test_incompatible_schema_rolls_back(self):
        with sqlite3.connect(self.path) as db:
            db.execute("CREATE TABLE tasks(id TEXT PRIMARY KEY)")
        with self.assertRaises(RuntimeError):
            TaskStore(self.path)
        with sqlite3.connect(self.path) as db:
            self.assertEqual(db.execute("PRAGMA user_version").fetchone()[0], 0)

    def test_active_transaction_rejected(self):
        with sqlite3.connect(self.path) as db:
            db.execute("CREATE TABLE x (id INTEGER)")
            db.execute("INSERT INTO x VALUES(1)")
            with self.assertRaises(ValueError):
                migrate(db)

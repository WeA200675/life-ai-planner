import sqlite3
import tempfile
import unittest
from pathlib import Path

from packages.storage.backup import backup_database, restore_database
from packages.storage.sqlite_store import TaskStore, StoredTask


class BackupTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.source = self.root / "source.db"
        self.backup = self.root / "snapshot.db"
        TaskStore(self.source).put(StoredTask("one", "Offline", 25))

    def test_backup_and_restore_preserve_tasks(self):
        backup_database(self.source, self.backup)
        restored = self.root / "restored.db"
        restore_database(self.backup, restored)
        self.assertEqual(TaskStore(restored).get("one").title, "Offline")

    def test_backup_is_independent_snapshot(self):
        backup_database(self.source, self.backup)
        TaskStore(self.source).put(StoredTask("two", "Later", 10))
        self.assertIsNone(TaskStore(self.backup).get("two"))

    def test_existing_destination_never_overwritten(self):
        self.backup.write_bytes(b"existing")
        with self.assertRaises(FileExistsError):
            backup_database(self.source, self.backup)
        self.assertEqual(self.backup.read_bytes(), b"existing")

    def test_restore_refuses_overwrite(self):
        backup_database(self.source, self.backup)
        with self.assertRaises(FileExistsError):
            restore_database(self.backup, self.source)

    def test_corrupt_backup_rejected(self):
        self.backup.write_bytes(b"not sqlite")
        with self.assertRaises(sqlite3.DatabaseError):
            restore_database(self.backup, self.root / "restored.db")
        self.assertFalse((self.root / "restored.db").exists())

    def test_future_schema_rejected(self):
        with sqlite3.connect(self.source) as db:
            db.execute("PRAGMA user_version=99")
        with self.assertRaises(ValueError):
            backup_database(self.source, self.backup)
        self.assertFalse(self.backup.exists())

    def test_missing_source_rejected(self):
        with self.assertRaises(ValueError):
            backup_database(self.root / "missing.db", self.backup)

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

    def test_wal_snapshot_includes_committed_rows_without_checkpoint(self):
        # A WAL writer can leave committed changes in -wal rather than the main file.
        writer = sqlite3.connect(self.source)
        self.addCleanup(writer.close)
        writer.execute("PRAGMA journal_mode=WAL")
        writer.execute(
            "INSERT INTO tasks(id, title, minutes, priority, deadline, status) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            ("wal-row", "Committed in WAL", 15, 0, None, "open"),
        )
        writer.commit()
        backup_database(self.source, self.backup)
        self.assertEqual(TaskStore(self.backup).get("wal-row").title, "Committed in WAL")

    def test_snapshot_excludes_uncommitted_wal_rows(self):
        writer = sqlite3.connect(self.source)
        self.addCleanup(writer.close)
        writer.execute("PRAGMA journal_mode=WAL")
        writer.execute(
            "INSERT INTO tasks(id, title, minutes, priority, deadline, status) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            ("pending", "Uncommitted", 15, 0, None, "open"),
        )
        try:
            backup_database(self.source, self.backup)
        finally:
            writer.rollback()
        self.assertIsNone(TaskStore(self.backup).get("pending"))

    def test_backup_rejects_orphaned_foreign_key_rows(self):
        # quick_check alone accepts this database; foreign_key_check must reject it.
        with sqlite3.connect(self.source) as db:
            db.execute("PRAGMA foreign_keys=OFF")
            db.execute("CREATE TABLE parent (id INTEGER PRIMARY KEY)")
            db.execute("CREATE TABLE child (parent_id INTEGER REFERENCES parent(id))")
            db.execute("INSERT INTO child(parent_id) VALUES (999)")
        with self.assertRaisesRegex(ValueError, "foreign key"):
            backup_database(self.source, self.backup)
        self.assertFalse(self.backup.exists())

    def test_restore_rejects_orphaned_foreign_key_rows(self):
        with sqlite3.connect(self.source) as db:
            db.execute("CREATE TABLE parent (id INTEGER PRIMARY KEY)")
            db.execute("CREATE TABLE child (parent_id INTEGER REFERENCES parent(id))")
            db.execute("INSERT INTO child(parent_id) VALUES (999)")
        # Build an intentionally invalid candidate without using guarded backup.
        with sqlite3.connect(self.source) as src, sqlite3.connect(self.backup) as dst:
            src.backup(dst)
        target = self.root / "restored.db"
        with self.assertRaisesRegex(ValueError, "foreign key"):
            restore_database(self.backup, target)
        self.assertFalse(target.exists())

    def test_backup_rejects_symlinked_source(self):
        alias = self.root / "source-alias.db"
        alias.symlink_to(self.source)
        with self.assertRaisesRegex(ValueError, "single regular"):
            backup_database(alias, self.backup)
        self.assertFalse(self.backup.exists())

    def test_restore_rejects_symlinked_backup(self):
        backup_database(self.source, self.backup)
        alias = self.root / "backup-alias.db"
        alias.symlink_to(self.backup)
        target = self.root / "restored.db"
        with self.assertRaisesRegex(ValueError, "single regular"):
            restore_database(alias, target)
        self.assertFalse(target.exists())

    def test_backup_rejects_hardlinked_source(self):
        alias = self.root / "hardlink.db"
        import os
        os.link(self.source, alias)
        with self.assertRaisesRegex(ValueError, "single regular"):
            backup_database(alias, self.backup)
        self.assertFalse(self.backup.exists())

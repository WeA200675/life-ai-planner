"""Synthetic file-based tests; no personal data."""
from pathlib import Path
import sqlite3
import tempfile
import unittest
from unittest.mock import patch

from packages.storage.sqlite_backup import snapshot, restore_cold


class SQLiteBackupTests(unittest.TestCase):
    def test_wal_snapshot_and_cold_restore(self):
        with tempfile.TemporaryDirectory() as directory:
            live, backup = Path(directory) / "live.db", Path(directory) / "backup.db"
            db = sqlite3.connect(live)
            db.execute("PRAGMA journal_mode=WAL")
            db.execute("CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT)")
            db.execute("INSERT INTO tasks VALUES (1, 'original')")
            db.commit()
            db.close()
            writer = sqlite3.connect(live)
            writer.execute("PRAGMA journal_mode=WAL")
            writer.execute("UPDATE tasks SET title='snapshot'")
            writer.commit()
            snapshot(live, backup)
            with sqlite3.connect(backup) as check:
                self.assertEqual(check.execute("SELECT title FROM tasks").fetchone()[0], "snapshot")
            check.close()
            writer.close()
            change = sqlite3.connect(live)
            change.execute("UPDATE tasks SET title='changed'")
            change.commit()
            change.close()
            checkpoint = sqlite3.connect(live)
            checkpoint.execute("PRAGMA wal_checkpoint(TRUNCATE)")
            checkpoint.execute("PRAGMA journal_mode=DELETE")
            checkpoint.close()
            restore_cold(backup, live)
            with sqlite3.connect(live) as restored:
                self.assertEqual(restored.execute("SELECT title FROM tasks").fetchone()[0], "snapshot")

    def test_corrupt_backup_keeps_live_database(self):
        with tempfile.TemporaryDirectory() as directory:
            live, backup = Path(directory) / "live.db", Path(directory) / "bad.db"
            with sqlite3.connect(live) as db:
                db.execute("CREATE TABLE items (x INTEGER)")
                db.execute("INSERT INTO items VALUES (7)")
            db.close()
            backup.write_bytes(b"not a database")
            with self.assertRaises(sqlite3.DatabaseError):
                restore_cold(backup, live)
            with sqlite3.connect(live) as check:
                self.assertEqual(check.execute("SELECT x FROM items").fetchone()[0], 7)

    def test_sidecar_prevents_restore(self):
        with tempfile.TemporaryDirectory() as directory:
            live, backup = Path(directory) / "live.db", Path(directory) / "backup.db"
            with sqlite3.connect(live) as db:
                db.execute("CREATE TABLE t (x INTEGER)")
            db.close()
            snapshot(live, backup)
            Path(str(live) + "-wal").write_bytes(b"")
            with self.assertRaises(RuntimeError):
                restore_cold(backup, live)


    def test_snapshot_refuses_to_overwrite_existing_recovery_point(self):
        with tempfile.TemporaryDirectory() as directory:
            live, backup = Path(directory) / "live.db", Path(directory) / "backup.db"
            with sqlite3.connect(live) as db:
                db.execute("CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT)")
                db.execute("INSERT INTO tasks VALUES (1, 'first')")
            snapshot(live, backup)
            original = backup.read_bytes()
            with sqlite3.connect(live) as db:
                db.execute("UPDATE tasks SET title='second' WHERE id=1")
            with self.assertRaises(FileExistsError):
                snapshot(live, backup)
            self.assertEqual(backup.read_bytes(), original)
            with sqlite3.connect(backup) as check:
                self.assertEqual(
                    check.execute("SELECT title FROM tasks WHERE id=1").fetchone()[0],
                    "first",
                )

    def test_snapshot_fsyncs_image_and_published_directory(self):
        with tempfile.TemporaryDirectory() as directory:
            live, backup = Path(directory) / "live.db", Path(directory) / "backup.db"
            with sqlite3.connect(live) as db:
                db.execute("CREATE TABLE t (id INTEGER PRIMARY KEY)")
                db.execute("INSERT INTO t VALUES (42)")
            with patch("packages.storage.sqlite_backup.os.fsync", wraps=__import__("os").fsync) as sync:
                snapshot(live, backup)
            self.assertEqual(sync.call_count, 2)
            with sqlite3.connect(backup) as check:
                self.assertEqual(check.execute("SELECT id FROM t").fetchone()[0], 42)

    def test_cold_restore_fsyncs_image_and_directory(self):
        with tempfile.TemporaryDirectory() as directory:
            live, backup = Path(directory) / "live.db", Path(directory) / "backup.db"
            with sqlite3.connect(live) as db:
                db.execute("CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT)")
                db.execute("INSERT INTO tasks VALUES (1, 'before')")
            snapshot(live, backup)
            with sqlite3.connect(live) as db:
                db.execute("UPDATE tasks SET title='after' WHERE id=1")
            with patch("packages.storage.sqlite_backup.os.fsync", wraps=__import__("os").fsync) as sync:
                restore_cold(backup, live)
            self.assertEqual(sync.call_count, 2)
            with sqlite3.connect(live) as restored:
                self.assertEqual(restored.execute("SELECT title FROM tasks").fetchone()[0], "before")

    def test_snapshot_refuses_to_replace_non_database_file(self):
        with tempfile.TemporaryDirectory() as directory:
            live, backup = Path(directory) / "live.db", Path(directory) / "backup.db"
            with sqlite3.connect(live) as db:
                db.execute("CREATE TABLE t (id INTEGER)")
            backup.write_bytes(b"important previous recovery data")
            with self.assertRaises(FileExistsError):
                snapshot(live, backup)
            self.assertEqual(backup.read_bytes(), b"important previous recovery data")

    def test_snapshot_rejects_symlink_destination_without_touching_target(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            live, protected, link = root / "live.db", root / "protected.db", root / "backup.db"
            with sqlite3.connect(live) as db:
                db.execute("CREATE TABLE t (x INTEGER)")
            protected.write_bytes(b"protected")
            link.symlink_to(protected)
            with self.assertRaises(ValueError):
                snapshot(live, link)
            self.assertEqual(protected.read_bytes(), b"protected")

    def test_cold_restore_rejects_symlink_backup_and_target(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            live, backup = root / "live.db", root / "backup.db"
            with sqlite3.connect(live) as db:
                db.execute("CREATE TABLE t (x INTEGER)")
                db.execute("INSERT INTO t VALUES (7)")
            snapshot(live, backup)
            alias = root / "alias.db"
            alias.symlink_to(backup)
            with self.assertRaises(ValueError):
                restore_cold(alias, live)
            target_link = root / "target.db"
            target_link.symlink_to(live)
            with self.assertRaises(ValueError):
                restore_cold(backup, target_link)
            with sqlite3.connect(live) as db:
                self.assertEqual(db.execute("SELECT x FROM t").fetchone()[0], 7)

if __name__ == "__main__":
    unittest.main()

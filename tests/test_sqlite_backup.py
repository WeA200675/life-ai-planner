"""Synthetic file-based tests; no personal data."""
from pathlib import Path
import sqlite3
import tempfile
import unittest

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


if __name__ == "__main__":
    unittest.main()

"""Synthetic v4 schema tests: no private data or live DB mutation."""
import sqlite3
import tempfile
import unittest
from pathlib import Path

from packages.storage.android_schema_contract import inspect_android_v4_candidate
from packages.storage.recovery_preflight import RecoveryPreflightError


class AndroidSchemaContractTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.path = Path(self.temp.name) / "candidate.db"
        with sqlite3.connect(self.path) as db:
            db.executescript("""
                CREATE TABLE tasks (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT NOT NULL, done INTEGER NOT NULL,
                    minutes INTEGER, priority INTEGER NOT NULL,
                    deadline_utc_ms INTEGER
                );
                CREATE TABLE plan_snapshots (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    created_utc_ms INTEGER NOT NULL,
                    window_start_utc_ms INTEGER NOT NULL,
                    window_end_utc_ms INTEGER NOT NULL,
                    budget_minutes INTEGER NOT NULL,
                    reserved_minutes INTEGER NOT NULL
                );
                CREATE TABLE plan_snapshot_blocks (
                    snapshot_id INTEGER NOT NULL,
                    position INTEGER NOT NULL,
                    task_id TEXT NOT NULL,
                    start_utc_ms INTEGER NOT NULL,
                    end_utc_ms INTEGER NOT NULL,
                    PRIMARY KEY(snapshot_id, position),
                    FOREIGN KEY(snapshot_id) REFERENCES plan_snapshots(id)
                );
                PRAGMA user_version=4;
                INSERT INTO tasks(title, done, priority)
                VALUES ('synthetic', 0, 0);
            """)

    def test_complete_v4_accepted_without_mutation(self):
        original = self.path.read_bytes()
        result = inspect_android_v4_candidate(self.path)
        self.assertEqual(result["user_version"], 4)
        self.assertEqual(len(result["tables"]), 3)
        self.assertEqual(self.path.read_bytes(), original)

    def test_wrong_schema_version_rejected(self):
        with sqlite3.connect(self.path) as db:
            db.execute("PRAGMA user_version=3")
        with self.assertRaisesRegex(RecoveryPreflightError, "schema"):
            inspect_android_v4_candidate(self.path)

    def test_missing_snapshot_table_rejected(self):
        with sqlite3.connect(self.path) as db:
            db.execute("DROP TABLE plan_snapshot_blocks")
        with self.assertRaises(RecoveryPreflightError):
            inspect_android_v4_candidate(self.path)

    def test_missing_task_deadline_column_rejected(self):
        with sqlite3.connect(self.path) as db:
            db.execute("ALTER TABLE tasks DROP COLUMN deadline_utc_ms")
        with self.assertRaisesRegex(RecoveryPreflightError, "columns"):
            inspect_android_v4_candidate(self.path)

    def test_missing_snapshot_block_column_rejected(self):
        with sqlite3.connect(self.path) as db:
            db.execute("ALTER TABLE plan_snapshot_blocks DROP COLUMN end_utc_ms")
        with self.assertRaisesRegex(RecoveryPreflightError, "columns"):
            inspect_android_v4_candidate(self.path)

    def test_corrupt_database_rejected(self):
        self.path.write_bytes(b"not a database" * 100)
        with self.assertRaises(RecoveryPreflightError):
            inspect_android_v4_candidate(self.path)

    def test_sqlite_sidecar_rejected(self):
        sidecar = Path(str(self.path) + "-wal")
        sidecar.write_bytes(b"synthetic")
        with self.assertRaisesRegex(RecoveryPreflightError, "sidecar"):
            inspect_android_v4_candidate(self.path)
        self.assertEqual(sidecar.read_bytes(), b"synthetic")

    def test_task_table_without_primary_key_rejected(self):
        with sqlite3.connect(self.path) as db:
            db.executescript("""
                DROP TABLE tasks;
                CREATE TABLE tasks (
                    id INTEGER, title TEXT, done INTEGER, minutes INTEGER,
                    priority INTEGER, deadline_utc_ms INTEGER
                );
            """)
        with self.assertRaisesRegex(RecoveryPreflightError, "primary key"):
            inspect_android_v4_candidate(self.path)

    def test_reversed_composite_primary_key_rejected(self):
        with sqlite3.connect(self.path) as db:
            db.executescript("""
                DROP TABLE plan_snapshot_blocks;
                CREATE TABLE plan_snapshot_blocks (
                    snapshot_id INTEGER, position INTEGER, task_id TEXT,
                    start_utc_ms INTEGER, end_utc_ms INTEGER,
                    PRIMARY KEY(position, snapshot_id)
                );
            """)
        with self.assertRaisesRegex(RecoveryPreflightError, "primary key"):
            inspect_android_v4_candidate(self.path)


    def test_missing_required_not_null_rejected(self):
        with sqlite3.connect(self.path) as db:
            db.executescript("""
                DROP TABLE tasks;
                CREATE TABLE tasks (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT, done INTEGER NOT NULL,
                    minutes INTEGER, priority INTEGER NOT NULL,
                    deadline_utc_ms INTEGER
                );
            """)
        with self.assertRaisesRegex(RecoveryPreflightError, "NOT NULL"):
            inspect_android_v4_candidate(self.path)

    def test_missing_snapshot_foreign_key_rejected(self):
        with sqlite3.connect(self.path) as db:
            db.executescript("""
                DROP TABLE plan_snapshot_blocks;
                CREATE TABLE plan_snapshot_blocks (
                    snapshot_id INTEGER NOT NULL, position INTEGER NOT NULL,
                    task_id TEXT NOT NULL, start_utc_ms INTEGER NOT NULL,
                    end_utc_ms INTEGER NOT NULL,
                    PRIMARY KEY(snapshot_id, position)
                );
            """)
        with self.assertRaisesRegex(RecoveryPreflightError, "foreign key"):
            inspect_android_v4_candidate(self.path)

    def test_wrong_snapshot_foreign_key_target_rejected(self):
        with sqlite3.connect(self.path) as db:
            db.executescript("""
                DROP TABLE plan_snapshot_blocks;
                CREATE TABLE plan_snapshot_blocks (
                    snapshot_id INTEGER NOT NULL, position INTEGER NOT NULL,
                    task_id TEXT NOT NULL, start_utc_ms INTEGER NOT NULL,
                    end_utc_ms INTEGER NOT NULL,
                    PRIMARY KEY(snapshot_id, position),
                    FOREIGN KEY(snapshot_id) REFERENCES tasks(id)
                );
            """)
        with self.assertRaisesRegex(RecoveryPreflightError, "foreign key"):
            inspect_android_v4_candidate(self.path)


if __name__ == "__main__":
    unittest.main()

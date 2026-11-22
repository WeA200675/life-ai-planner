import os
from pathlib import Path
import sqlite3
import tempfile
import unittest
from unittest.mock import patch

from packages.storage.recovery_preflight import RecoveryPreflightError, inspect_candidate


class RecoveryPreflightTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.path = Path(self.tmp.name) / "candidate.db"
        with sqlite3.connect(self.path) as db:
            db.execute("CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT)")
            db.execute("INSERT INTO tasks(title) VALUES ('synthetic')")
            db.execute("PRAGMA user_version = 4")

    def test_valid_snapshot_does_not_modify_file(self):
        before = self.path.read_bytes()
        result = inspect_candidate(self.path, expected_user_version=4)
        self.assertEqual(result["tables"], ["tasks"])
        self.assertEqual(self.path.read_bytes(), before)

    def test_wrong_schema_rejected(self):
        with self.assertRaisesRegex(RecoveryPreflightError, "schema"):
            inspect_candidate(self.path, expected_user_version=3)

    def test_corruption_rejected(self):
        self.path.write_bytes(b"x" * 4096)
        with self.assertRaises(RecoveryPreflightError):
            inspect_candidate(self.path)

    def test_sidecar_rejected(self):
        sidecar = Path(str(self.path) + "-wal")
        sidecar.write_bytes(b"synthetic")
        with self.assertRaisesRegex(RecoveryPreflightError, "sidecar"):
            inspect_candidate(self.path)
        self.assertEqual(sidecar.read_bytes(), b"synthetic")

    def test_sidecar_appearing_during_inspection_rejected(self):
        real_connect = sqlite3.connect
        sidecar = Path(str(self.path) + "-wal")

        def concurrent_sidecar(*args, **kwargs):
            connection = real_connect(*args, **kwargs)
            sidecar.write_bytes(b"synthetic concurrent sidecar")
            return connection

        with patch("packages.storage.recovery_preflight.sqlite3.connect",
                   side_effect=concurrent_sidecar):
            with self.assertRaisesRegex(RecoveryPreflightError, "sidecar"):
                inspect_candidate(self.path)
        self.assertEqual(sidecar.read_bytes(), b"synthetic concurrent sidecar")

    def test_symlink_rejected(self):
        if not hasattr(os, "symlink"):
            self.skipTest("symlinks unavailable")
        link = Path(self.tmp.name) / "linked.db"
        try:
            link.symlink_to(self.path)
        except OSError:
            self.skipTest("symlink creation not permitted")
        with self.assertRaisesRegex(RecoveryPreflightError, "symlink"):
            inspect_candidate(link)

    def test_orphaned_foreign_key_rejected_without_modifying_candidate(self):
        with sqlite3.connect(self.path) as db:
            db.execute("CREATE TABLE parents (id INTEGER PRIMARY KEY)")
            db.execute("CREATE TABLE children (parent_id INTEGER REFERENCES parents(id))")
            db.execute("INSERT INTO children(parent_id) VALUES (999)")
        before = self.path.read_bytes()
        with self.assertRaisesRegex(RecoveryPreflightError, "foreign key"):
            inspect_candidate(self.path, expected_user_version=4)
        self.assertEqual(self.path.read_bytes(), before)

    def test_valid_foreign_key_relationship_accepted(self):
        with sqlite3.connect(self.path) as db:
            db.execute("CREATE TABLE parents (id INTEGER PRIMARY KEY)")
            db.execute("CREATE TABLE children (parent_id INTEGER REFERENCES parents(id))")
            db.execute("INSERT INTO parents(id) VALUES (1)")
            db.execute("INSERT INTO children(parent_id) VALUES (1)")
        result = inspect_candidate(self.path, expected_user_version=4)
        self.assertEqual(result["tables"], ["children", "parents", "tasks"])

    def test_required_tables_present(self):
        result = inspect_candidate(
            self.path, expected_user_version=4, required_tables=("tasks",))
        self.assertIn("tasks", result["tables"])

    def test_missing_application_table_rejected_without_mutation(self):
        before = self.path.read_bytes()
        with self.assertRaisesRegex(RecoveryPreflightError, "required application"):
            inspect_candidate(self.path, required_tables=("tasks", "plan_snapshots"))
        self.assertEqual(self.path.read_bytes(), before)

    def test_invalid_required_table_names_rejected(self):
        for names in (("tasks; DROP TABLE tasks",), ("",), ("tâsk",), "tasks"):
            with self.subTest(names=names):
                with self.assertRaisesRegex(RecoveryPreflightError, "table names"):
                    inspect_candidate(self.path, required_tables=names)

    def test_missing_and_invalid_version_rejected(self):
        with self.assertRaises(RecoveryPreflightError):
            inspect_candidate(Path(self.tmp.name) / "missing.db")
        with self.assertRaises(RecoveryPreflightError):
            inspect_candidate(self.path, expected_user_version=True)


    def test_read_only_connection_closed_on_success_and_schema_rejection(self):
        real_connect = sqlite3.connect
        connections = []

        class TrackedConnection:
            def __init__(self, wrapped):
                self.wrapped = wrapped
                self.closed = False

            def execute(self, *args, **kwargs):
                return self.wrapped.execute(*args, **kwargs)

            def close(self):
                self.closed = True
                self.wrapped.close()

        def tracked_connect(*args, **kwargs):
            tracked = TrackedConnection(real_connect(*args, **kwargs))
            connections.append(tracked)
            return tracked

        with patch("packages.storage.recovery_preflight.sqlite3.connect",
                   side_effect=tracked_connect):
            inspect_candidate(self.path, expected_user_version=4)
            with self.assertRaisesRegex(RecoveryPreflightError, "schema"):
                inspect_candidate(self.path, expected_user_version=3)
        self.assertEqual(len(connections), 2)
        self.assertTrue(all(connection.closed for connection in connections))


    def test_same_size_write_with_restored_mtime_rejected(self):
        # A concurrent writer can preserve size and restore mtime. ctime
        # still changes on supported filesystems, invalidating preflight.
        real_connect = sqlite3.connect
        original = self.path.stat()
        original_bytes = self.path.read_bytes()

        def concurrent_write(*args, **kwargs):
            connection = real_connect(*args, **kwargs)
            with self.path.open("r+b") as handle:
                handle.seek(200)
                value = handle.read(1)
                handle.seek(200)
                handle.write(value)
                handle.flush()
                os.fsync(handle.fileno())
            os.utime(self.path, ns=(original.st_atime_ns, original.st_mtime_ns))
            return connection

        with patch("packages.storage.recovery_preflight.sqlite3.connect",
                   side_effect=concurrent_write):
            with self.assertRaisesRegex(RecoveryPreflightError, "changed"):
                inspect_candidate(self.path, expected_user_version=4)
        self.assertEqual(self.path.read_bytes(), original_bytes)
        self.assertEqual(self.path.stat().st_mtime_ns, original.st_mtime_ns)

    def test_candidate_disappearing_after_read_fails_closed(self):
        real_lstat = Path.lstat
        calls = 0

        def disappearing_lstat(path, *args, **kwargs):
            nonlocal calls
            if path == self.path:
                calls += 1
                # _regular_private_file checks the candidate twice; the
                # third call is the post-inspection identity check.
                if calls >= 3:
                    raise FileNotFoundError("simulated concurrent removal")
            return real_lstat(path, *args, **kwargs)

        with patch("packages.storage.recovery_preflight.Path.lstat",
                   autospec=True, side_effect=disappearing_lstat):
            with self.assertRaisesRegex(RecoveryPreflightError, "vanished"):
                inspect_candidate(self.path, expected_user_version=4)
        self.assertTrue(self.path.exists())


    def test_required_columns_present_and_read_only(self):
        before = self.path.read_bytes()
        result = inspect_candidate(self.path, expected_user_version=4,
                                   required_columns={"tasks": ("id", "title")})
        self.assertEqual(result["tables"], ["tasks"])
        self.assertEqual(self.path.read_bytes(), before)

    def test_missing_columns_and_tables_fail_closed(self):
        before = self.path.read_bytes()
        for contract in ({"tasks": ("id", "missing")},
                         {"missing_table": ("id",)}):
            with self.subTest(contract=contract):
                with self.assertRaisesRegex(RecoveryPreflightError,
                                            "required application columns"):
                    inspect_candidate(self.path, required_columns=contract)
        self.assertEqual(self.path.read_bytes(), before)

    def test_invalid_column_contracts_rejected_without_sql_execution(self):
        for contract in ({"tasks": ("title; DROP TABLE tasks",)},
                         {"tasks": ()}, {"tasks": "title"},
                         {"tasks": ("",)}, {"bad-table": ("id",)},
                         {"tasks": (1,)}, ["tasks"]):
            with self.subTest(contract=contract):
                with self.assertRaisesRegex(RecoveryPreflightError,
                                            "required column names"):
                    inspect_candidate(self.path, required_columns=contract)
        self.assertEqual(inspect_candidate(self.path)["tables"], ["tasks"])

    def test_column_contract_does_not_accept_index_or_view_as_table(self):
        with sqlite3.connect(self.path) as db:
            db.execute("CREATE VIEW task_view AS SELECT id, title FROM tasks")
        with self.assertRaisesRegex(RecoveryPreflightError, "required application"):
            inspect_candidate(self.path, required_tables=("task_view",))


if __name__ == "__main__":
    unittest.main()

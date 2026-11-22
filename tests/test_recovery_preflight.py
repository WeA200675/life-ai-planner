import os
from pathlib import Path
import sqlite3
import tempfile
import unittest

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

    def test_missing_and_invalid_version_rejected(self):
        with self.assertRaises(RecoveryPreflightError):
            inspect_candidate(Path(self.tmp.name) / "missing.db")
        with self.assertRaises(RecoveryPreflightError):
            inspect_candidate(self.path, expected_user_version=True)


if __name__ == "__main__":
    unittest.main()

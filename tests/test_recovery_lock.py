import json
import os
from pathlib import Path
import tempfile
import unittest

from packages.storage.recovery_lock import advance_phase_locked, recovery_lock
from packages.storage.recovery_phase import RecoveryPhaseError, read_phase


@unittest.skipUnless(os.name == "posix", "POSIX advisory lock only")
class RecoveryLockTests(unittest.TestCase):
    def test_lock_contention_and_reacquisition(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "restore.lock"
            with recovery_lock(path):
                with self.assertRaisesRegex(RecoveryPhaseError, "already locked"):
                    with recovery_lock(path):
                        pass
            with recovery_lock(path):
                self.assertTrue(path.exists())

    def test_locked_phase_advance(self):
        with tempfile.TemporaryDirectory() as directory:
            journal = Path(directory) / "journal"
            lock = Path(directory) / "restore.lock"
            journal.write_text(json.dumps({"phase": "prepared", "restore_id": "synthetic"}))
            advance_phase_locked(journal, lock, "synthetic", "prepared", "original_saved")
            self.assertEqual(read_phase(journal)["phase"], "original_saved")
            with self.assertRaises(RecoveryPhaseError):
                advance_phase_locked(journal, lock, "synthetic", "prepared", "original_saved")
            self.assertEqual(read_phase(journal)["phase"], "original_saved")

    def test_symlink_lock_rejected_without_modification(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "target"
            target.write_text("unchanged")
            link = Path(directory) / "link"
            link.symlink_to(target)
            with self.assertRaises(RecoveryPhaseError):
                with recovery_lock(link):
                    pass
            self.assertEqual(target.read_text(), "unchanged")

    def test_lock_file_is_not_deleted(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "restore.lock"
            with recovery_lock(path):
                inode = path.stat().st_ino
            self.assertEqual(path.stat().st_ino, inode)


if __name__ == "__main__":
    unittest.main()

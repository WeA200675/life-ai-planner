import json
from pathlib import Path
import tempfile
import unittest

from packages.storage.recovery_phase import RecoveryPhaseError, advance_phase, read_phase


class RecoveryPhaseTests(unittest.TestCase):
    def test_full_sequence(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "journal"
            path.write_text(json.dumps({"restore_id": "synthetic-1", "phase": "prepared"}))
            for before, after in [("prepared", "original_saved"), ("original_saved", "candidate_activated"), ("candidate_activated", "verified")]:
                advance_phase(path, "synthetic-1", before, after)
                self.assertEqual(read_phase(path)["phase"], after)

    def test_stale_transition_preserves_bytes(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "journal"
            original = b'{"phase":"prepared","restore_id":"synthetic"}'
            path.write_bytes(original)
            with self.assertRaises(RecoveryPhaseError):
                advance_phase(path, "synthetic", "prepared", "verified")
            with self.assertRaises(RecoveryPhaseError):
                advance_phase(path, "other", "prepared", "original_saved")
            self.assertEqual(path.read_bytes(), original)

    def test_missing_and_invalid_journal(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "journal"
            with self.assertRaises(RecoveryPhaseError):
                advance_phase(path, "x", "prepared", "original_saved")
            path.write_bytes(b"not-json")
            with self.assertRaises(RecoveryPhaseError):
                read_phase(path)

    def test_symlink_rejected(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            target = root / "target"
            target.write_text('{"phase":"prepared","restore_id":"synthetic"}')
            link = root / "link"
            link.symlink_to(target)
            with self.assertRaises(RecoveryPhaseError):
                advance_phase(link, "synthetic", "prepared", "original_saved")
            self.assertIn("prepared", target.read_text())

    def test_oversized_and_unknown_fields(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "journal"
            path.write_bytes(b" " * 16385)
            with self.assertRaises(RecoveryPhaseError):
                read_phase(path)
            path.write_text('{"phase":"prepared","restore_id":"synthetic","extra":1}')
            with self.assertRaises(RecoveryPhaseError):
                read_phase(path)


if __name__ == "__main__":
    unittest.main()

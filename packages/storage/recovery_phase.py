"""Fail-closed, atomic recovery phase journal. Never swaps a database."""
import json
import os
from pathlib import Path
import stat
import tempfile

PHASES = ("prepared", "original_saved", "candidate_activated", "verified")
MAX_BYTES = 16384


class RecoveryPhaseError(ValueError):
    """Invalid or unsafe recovery transition."""


def _safe_path(path):
    path = Path(os.path.abspath(path))
    for item in (path, *path.parents):
        try:
            mode = item.lstat().st_mode
        except FileNotFoundError:
            continue
        if stat.S_ISLNK(mode):
            raise RecoveryPhaseError("symlink in journal path")
    if not path.parent.is_dir():
        raise RecoveryPhaseError("missing parent directory")


def _decode(raw):
    if len(raw) > MAX_BYTES:
        raise RecoveryPhaseError("oversized journal")
    try:
        data = json.loads(raw.decode("utf-8"))
    except (ValueError, UnicodeError) as exc:
        raise RecoveryPhaseError("invalid journal") from exc
    if not isinstance(data, dict) or set(data) != {"phase", "restore_id"}:
        raise RecoveryPhaseError("unexpected fields")
    identifier = data["restore_id"]
    if (data["phase"] not in PHASES or not isinstance(identifier, str)
            or not 1 <= len(identifier) <= 128 or not identifier.isascii()
            or not all(ch.isalnum() or ch in "-_" for ch in identifier)):
        raise RecoveryPhaseError("invalid journal state")
    return data


def read_phase(path):
    path = Path(path)
    _safe_path(path)
    try:
        with path.open("rb") as stream:
            return _decode(stream.read(MAX_BYTES + 1))
    except FileNotFoundError as exc:
        raise RecoveryPhaseError("journal missing") from exc


def advance_phase(path, restore_id, expected, next_phase):
    """Advance exactly one phase; caller must hold an external exclusive lock.

    This is not a cross-process compare-and-swap. Database connections must be
    closed and WAL state settled by the higher-level restore coordinator.
    """
    path = Path(path)
    _safe_path(path)
    current = read_phase(path)
    if current != {"restore_id": restore_id, "phase": expected}:
        raise RecoveryPhaseError("stale journal or wrong restore id")
    if expected not in PHASES[:-1] or PHASES[PHASES.index(expected) + 1] != next_phase:
        raise RecoveryPhaseError("invalid transition")
    payload = json.dumps({"phase": next_phase, "restore_id": restore_id}, sort_keys=True).encode()
    fd, temporary = tempfile.mkstemp(prefix=".recovery-phase-", dir=path.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            os.fchmod(stream.fileno(), 0o600)
            stream.write(payload)
            stream.flush()
            os.fsync(stream.fileno())
        _safe_path(path)
        if read_phase(path) != current:
            raise RecoveryPhaseError("journal changed during transition")
        os.replace(temporary, path)
        directory_fd = os.open(path.parent, os.O_RDONLY)
        try:
            os.fsync(directory_fd)
        finally:
            os.close(directory_fd)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)

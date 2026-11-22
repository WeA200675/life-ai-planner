"""Read-only, fail-closed SQLite restore candidate preflight.

Never activates, copies, checkpoints, or modifies a database.
"""
import os
from pathlib import Path
import sqlite3
import stat


class RecoveryPreflightError(ValueError):
    """Candidate is not safe to consider for activation."""


def _regular_private_file(path):
    path = Path(os.path.abspath(path))
    for part in (path, *path.parents):
        try:
            info = part.lstat()
        except FileNotFoundError as exc:
            raise RecoveryPreflightError("candidate path missing") from exc
        if stat.S_ISLNK(info.st_mode):
            raise RecoveryPreflightError("symlink in candidate path")
    info = path.lstat()
    if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1:
        raise RecoveryPreflightError("candidate is not a single regular file")
    if info.st_size < 100 or info.st_size > 1024 * 1024 * 1024:
        raise RecoveryPreflightError("candidate size outside supported range")
    return path, info


def inspect_candidate(path, *, expected_user_version=None):
    """Read-only validation; reject sidecars rather than ignore WAL data.

    Caller must separately hold an exclusive application-wide database lock.
    """
    candidate, before = _regular_private_file(path)
    if expected_user_version is not None and (
        type(expected_user_version) is not int or expected_user_version < 0
    ):
        raise RecoveryPreflightError("invalid expected schema version")
    for suffix in ("-wal", "-shm", "-journal"):
        if os.path.lexists(str(candidate) + suffix):
            raise RecoveryPreflightError("candidate has SQLite sidecar")
    uri = candidate.as_uri() + "?mode=ro&immutable=1"
    try:
        with sqlite3.connect(uri, uri=True, timeout=0) as db:
            integrity = db.execute("PRAGMA integrity_check").fetchall()
            if integrity != [("ok",)]:
                raise RecoveryPreflightError("SQLite integrity check failed")
            version = db.execute("PRAGMA user_version").fetchone()[0]
            tables = sorted(row[0] for row in db.execute(
                "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
            ))
    except sqlite3.DatabaseError as exc:
        raise RecoveryPreflightError("invalid SQLite candidate") from exc
    after = candidate.lstat()
    if (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns) != (
        after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns
    ):
        raise RecoveryPreflightError("candidate changed during inspection")
    if expected_user_version is not None and version != expected_user_version:
        raise RecoveryPreflightError("unexpected schema version")
    return {"user_version": version, "tables": tables, "size_bytes": after.st_size}

"""Consistent live SQLite snapshots and guarded cold restores.

Restore requires external exclusive access and a separate recovery copy.
"""
from __future__ import annotations
from contextlib import closing
from pathlib import Path
import os
import sqlite3
import tempfile


def _validate(path: Path) -> None:
    with closing(sqlite3.connect(f"file:{path}?mode=ro", uri=True)) as db:
        if db.execute("PRAGMA quick_check").fetchone()[0] != "ok":
            raise ValueError("SQLite integrity check failed")
        if db.execute("PRAGMA foreign_key_check").fetchone() is not None:
            raise ValueError("SQLite foreign key check failed")


def _stage(destination: Path) -> Path:
    destination.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(prefix=f".{destination.name}.", suffix=".tmp", dir=destination.parent)
    os.close(fd)
    return Path(name)


def snapshot(source: str | Path, destination: str | Path) -> Path:
    """Publish an integrity-checked online snapshot, including committed WAL data."""
    src, dst = Path(source), Path(destination)
    if not src.is_file() or src.resolve() == dst.resolve():
        raise ValueError("Invalid source or destination")
    if dst.exists():
        raise FileExistsError(f"Backup destination already exists: {dst}")
    temp = _stage(dst)
    try:
        with closing(sqlite3.connect(f"file:{src}?mode=ro", uri=True)) as origin:
            with sqlite3.connect(temp) as copy:
                origin.backup(copy)
        _validate(temp)
        # A snapshot must never silently destroy the only older recovery point.
        # Hard-link publication is atomic and fails if destination already exists.
        # Both paths are in the same directory/filesystem by construction.
        os.link(temp, dst)
        return dst
    finally:
        temp.unlink(missing_ok=True)


def restore_cold(backup: str | Path, target: str | Path) -> Path:
    """Atomically replace a CLOSED database; reject sidecars and corrupt backups.

    Caller must guarantee no other process can open the database during restore.
    This function does not replace a production backup/rollback coordinator.
    """
    src, dst = Path(backup), Path(target)
    if not src.is_file() or src.resolve() == dst.resolve():
        raise ValueError("Invalid backup or target")
    if any(Path(str(dst) + suffix).exists() for suffix in ("-wal", "-shm", "-journal")):
        raise RuntimeError("Active or stale SQLite sidecars: checkpoint and close before restore")
    _validate(src)
    temp = _stage(dst)
    try:
        with closing(sqlite3.connect(f"file:{src}?mode=ro", uri=True)) as origin:
            with sqlite3.connect(temp) as copy:
                origin.backup(copy)
        _validate(temp)
        os.replace(temp, dst)
        return dst
    finally:
        temp.unlink(missing_ok=True)

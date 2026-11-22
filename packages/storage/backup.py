"""Offline SQLite snapshot and guarded restore.

Backup uses SQLite's online backup API, not a raw copy (safe with WAL writers).
Restore is deliberately offline-only and refuses to overwrite any existing DB.
"""
from pathlib import Path
import stat
import os
import sqlite3
import tempfile

from packages.storage.migrations import CURRENT_VERSION


def _check_database(path: Path) -> None:
    # URI mode=ro prevents accidental creation of missing databases.
    with sqlite3.connect(path.as_uri() + "?mode=ro", uri=True) as db:
        if db.execute("PRAGMA quick_check").fetchone()[0] != "ok":
            raise ValueError("SQLite integrity check failed")
        # quick_check does not detect broken foreign-key relationships.
        # Validate all tables, including optional future extension tables.
        if db.execute("PRAGMA foreign_key_check").fetchone() is not None:
            raise ValueError("SQLite foreign key check failed")
        version = db.execute("PRAGMA user_version").fetchone()[0]
        if version != CURRENT_VERSION:
            raise ValueError(f"unsupported schema version: {version}")
        required = {"id", "title", "minutes", "priority", "deadline", "status"}
        columns = {row[1] for row in db.execute("PRAGMA table_info(tasks)")}
        if not required.issubset(columns):
            raise ValueError("missing tasks columns")


def backup_database(source: str | Path, destination: str | Path) -> Path:
    """Create a consistent snapshot; never replace an existing backup."""
    # Refuse symlinked inputs before resolve() erases that evidence.
    # This keeps backup/restore from silently following redirected database paths.
    source_input = Path(source).absolute()
    try:
        source_info = source_input.lstat()
    except FileNotFoundError as exc:
        raise ValueError("source database missing") from exc
    if not stat.S_ISREG(source_info.st_mode) or source_info.st_nlink != 1:
        raise ValueError("source must be a single regular database file")
    source, destination = source_input.resolve(), Path(destination).resolve()
    if not source.is_file() or source == destination:
        raise ValueError("source database missing or destination equals source")
    if destination.exists():
        raise FileExistsError(destination)
    destination.parent.mkdir(parents=True, exist_ok=True)
    fd, temporary = tempfile.mkstemp(prefix=".planner-backup-", suffix=".db",
                                    dir=destination.parent)
    os.close(fd)
    try:
        with sqlite3.connect(source.as_uri() + "?mode=ro", uri=True) as src:
            with sqlite3.connect(temporary) as dst:
                src.backup(dst)
        _check_database(Path(temporary))
        # Hard-link publication is exclusive and atomic on the same filesystem.
        os.link(temporary, destination)
        return destination
    finally:
        Path(temporary).unlink(missing_ok=True)


def restore_database(backup: str | Path, destination: str | Path) -> Path:
    """Restore into a NEW location only. Caller must close all DB connections."""
    backup_input = Path(backup).absolute()
    try:
        backup_info = backup_input.lstat()
    except FileNotFoundError as exc:
        raise ValueError("backup missing") from exc
    if not stat.S_ISREG(backup_info.st_mode) or backup_info.st_nlink != 1:
        raise ValueError("backup must be a single regular database file")
    backup, destination = backup_input.resolve(), Path(destination).resolve()
    if backup == destination or not backup.is_file():
        raise ValueError("backup missing or destination equals backup")
    _check_database(backup)
    return backup_database(backup, destination)

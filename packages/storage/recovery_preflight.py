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


def inspect_candidate(path, *, expected_user_version=None, required_tables=(),
                      required_columns=None, required_primary_keys=None,
                      required_not_null=None, required_foreign_keys=None):
    """Read-only validation; reject sidecars rather than ignore WAL data.

    Caller must separately hold an exclusive application-wide database lock.
    """
    candidate, before = _regular_private_file(path)
    if expected_user_version is not None and (
        type(expected_user_version) is not int or expected_user_version < 0
    ):
        raise RecoveryPreflightError("invalid expected schema version")
    if not isinstance(required_tables, (tuple, list, frozenset, set)) or any(
        not isinstance(name, str) or not name or
        not name.isascii() or not all(ch.isalnum() or ch == "_" for ch in name)
        for name in required_tables
    ):
        raise RecoveryPreflightError("invalid required table names")
    if required_columns is None:
        required_columns = {}
    if not isinstance(required_columns, dict) or any(
        not isinstance(table, str) or not table.isascii() or not table or
        not all(ch.isalnum() or ch == "_" for ch in table) or
        not isinstance(columns, (tuple, list, set, frozenset)) or not columns or
        any(not isinstance(col, str) or not col.isascii() or not col or
            not all(ch.isalnum() or ch == "_" for ch in col) for col in columns)
        for table, columns in required_columns.items()
    ):
        raise RecoveryPreflightError("invalid required column names")
    if required_primary_keys is None:
        required_primary_keys = {}
    if not isinstance(required_primary_keys, dict) or any(
        not isinstance(table, str) or not table.isidentifier() or not table.isascii() or
        not isinstance(keys, (tuple, list)) or not keys or
        any(not isinstance(key, str) or not key.isidentifier() or not key.isascii() for key in keys)
        for table, keys in required_primary_keys.items()
    ):
        raise RecoveryPreflightError("invalid required primary keys")
    if required_not_null is None:
        required_not_null = {}
    if not isinstance(required_not_null, dict) or any(
        not isinstance(table, str) or not table.isidentifier() or not table.isascii() or
        not isinstance(cols, (tuple, list, set, frozenset)) or not cols or
        any(not isinstance(col, str) or not col.isidentifier() or not col.isascii()
            for col in cols)
        for table, cols in required_not_null.items()
    ):
        raise RecoveryPreflightError("invalid NOT NULL contract")
    if required_foreign_keys is None:
        required_foreign_keys = {}
    if not isinstance(required_foreign_keys, dict) or any(
        not isinstance(table, str) or not table.isidentifier() or not table.isascii() or
        not isinstance(edges, (tuple, list)) or not edges or
        any(not isinstance(edge, (tuple, list)) or len(edge) != 3 or
            any(not isinstance(value, str) or not value.isidentifier() or
                not value.isascii() for value in edge) for edge in edges)
        for table, edges in required_foreign_keys.items()
    ):
        raise RecoveryPreflightError("invalid foreign key contract")
    for suffix in ("-wal", "-shm", "-journal"):
        if os.path.lexists(str(candidate) + suffix):
            raise RecoveryPreflightError("candidate has SQLite sidecar")
    uri = candidate.as_uri() + "?mode=ro&immutable=1"
    try:
        # sqlite3.Connection.__exit__ commits/rolls back but does NOT close.
        # Explicit closing prevents lingering handles on every error path.
        from contextlib import closing
        with closing(sqlite3.connect(uri, uri=True, timeout=0)) as db:
            integrity = db.execute("PRAGMA integrity_check").fetchall()
            if integrity != [("ok",)]:
                raise RecoveryPreflightError("SQLite integrity check failed")
            if db.execute("PRAGMA foreign_key_check").fetchone() is not None:
                raise RecoveryPreflightError("SQLite foreign key check failed")
            version = db.execute("PRAGMA user_version").fetchone()[0]
            tables = sorted(row[0] for row in db.execute(
                "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
            ))
            for table, columns in required_columns.items():
                if table not in tables:
                    raise RecoveryPreflightError("required application columns missing")
                # Names are validated above; quote identifiers defensively.
                present = {row[1] for row in db.execute(
                    'PRAGMA table_info("' + table + '")'
                )}
                if not set(columns).issubset(present):
                    raise RecoveryPreflightError("required application columns missing")
            for table, keys in required_primary_keys.items():
                if table not in tables:
                    raise RecoveryPreflightError("required primary key table missing")
                info = db.execute('PRAGMA table_info("' + table + '")').fetchall()
                actual = tuple(row[1] for row in sorted(info, key=lambda row: row[5]) if row[5] > 0)
                if actual != tuple(keys):
                    raise RecoveryPreflightError("required primary key mismatch")
            for table, cols in required_not_null.items():
                if table not in tables:
                    raise RecoveryPreflightError("required NOT NULL table missing")
                info = db.execute('PRAGMA table_info("' + table + '")').fetchall()
                actual = {row[1] for row in info if row[3] == 1}
                # SQLite reports INTEGER PRIMARY KEY as nullable in table_info,
                # even though the rowid alias is intrinsically non-null.
                actual.update(row[1] for row in info if row[5] > 0 and
                              row[2].upper() == "INTEGER" and len(
                                  [key for key in info if key[5] > 0]) == 1)
                if not set(cols).issubset(actual):
                    raise RecoveryPreflightError("required NOT NULL mismatch")
            for table, edges in required_foreign_keys.items():
                if table not in tables:
                    raise RecoveryPreflightError("required foreign key table missing")
                present = {(row[3], row[2], row[4]) for row in db.execute(
                    'PRAGMA foreign_key_list("' + table + '")'
                )}
                if not set(map(tuple, edges)).issubset(present):
                    raise RecoveryPreflightError("required foreign key mismatch")
    except sqlite3.DatabaseError as exc:
        raise RecoveryPreflightError("invalid SQLite candidate") from exc
    # A WAL/journal appearing during the read invalidates the immutable snapshot.
    # The coordinator must still exclude uncooperative writers externally.
    for suffix in ("-wal", "-shm", "-journal"):
        if os.path.lexists(str(candidate) + suffix):
            raise RecoveryPreflightError("candidate acquired SQLite sidecar during inspection")
    try:
        after = candidate.lstat()
    except OSError as exc:
        raise RecoveryPreflightError("candidate vanished during inspection") from exc
    if not stat.S_ISREG(after.st_mode) or after.st_nlink != 1:
        raise RecoveryPreflightError("candidate file type changed during inspection")
    if (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns, before.st_ctime_ns) != (
        after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns, after.st_ctime_ns
    ):
        raise RecoveryPreflightError("candidate changed during inspection")
    if expected_user_version is not None and version != expected_user_version:
        raise RecoveryPreflightError("unexpected schema version")
    if not set(required_tables).issubset(tables):
        raise RecoveryPreflightError("required application tables missing")
    return {"user_version": version, "tables": tables, "size_bytes": after.st_size}

"""Transactional, forward-only SQLite schema migration for local planner data.

No destructive migrations; unknown future versions are rejected before writes.
"""
import sqlite3

CURRENT_VERSION = 1

def migrate(db: sqlite3.Connection) -> int:
    """Upgrade a connection in one IMMEDIATE transaction, preserving existing rows.

    Caller must not have an active transaction. Concurrent migrators serialize.
    """
    if db.in_transaction:
        raise ValueError("migration requires an idle connection")
    db.execute("BEGIN IMMEDIATE")
    try:
        version = db.execute("PRAGMA user_version").fetchone()[0]
        if version > CURRENT_VERSION:
            raise RuntimeError(f"database version {version} is newer than supported {CURRENT_VERSION}")
        if version < 0:
            raise RuntimeError("invalid database version")
        if version == 0:
            # Existing prototype installations may have created tasks without
            # setting user_version; CREATE IF NOT EXISTS preserves those rows.
            db.execute("""CREATE TABLE IF NOT EXISTS tasks (
                id TEXT PRIMARY KEY NOT NULL,
                title TEXT NOT NULL,
                minutes INTEGER NOT NULL CHECK(minutes > 0),
                priority INTEGER NOT NULL DEFAULT 0,
                deadline TEXT,
                status TEXT NOT NULL DEFAULT 'open'
                  CHECK(status IN ('open','active','done','cancelled'))
            )""")
            columns = {row[1] for row in db.execute("PRAGMA table_info(tasks)")}
            expected = {"id", "title", "minutes", "priority", "deadline", "status"}
            if not expected.issubset(columns):
                raise RuntimeError("incompatible legacy tasks schema; manual recovery required")
            db.execute("PRAGMA user_version = 1")
        db.commit()
        return CURRENT_VERSION
    except BaseException:
        db.rollback()
        raise

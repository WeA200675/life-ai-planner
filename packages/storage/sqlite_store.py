"""SQLite task store for offline-first MVP; stdlib only.

Every operation uses a short-lived connection and an atomic transaction.
No network, cloud account or LLM required.
"""
from contextlib import contextmanager
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
import sqlite3

SCHEMA_VERSION = 1

@dataclass(frozen=True)
class StoredTask:
    id: str
    title: str
    minutes: int
    priority: int = 0
    deadline: str | None = None
    status: str = "open"

class TaskStore:
    def __init__(self, path: str | Path):
        self.path = str(path)
        if self.path == ":memory:":
            raise ValueError("use a filesystem database; in-memory databases cannot survive reconnects")
        Path(self.path).parent.mkdir(parents=True, exist_ok=True)
        with self._connection() as db:
            db.execute("""CREATE TABLE IF NOT EXISTS tasks (
                id TEXT PRIMARY KEY NOT NULL,
                title TEXT NOT NULL,
                minutes INTEGER NOT NULL CHECK(minutes > 0),
                priority INTEGER NOT NULL DEFAULT 0,
                deadline TEXT,
                status TEXT NOT NULL DEFAULT 'open'
                  CHECK(status IN ('open','active','done','cancelled'))
            )""")
            db.execute("PRAGMA user_version = 1")

    @contextmanager
    def _connection(self):
        db = sqlite3.connect(self.path, timeout=10)
        db.row_factory = sqlite3.Row
        db.execute("PRAGMA busy_timeout = 10000")
        try:
            yield db
            db.commit()
        except BaseException:
            db.rollback()
            raise
        finally:
            db.close()

    @staticmethod
    def _validate(task: StoredTask):
        if not task.id.strip() or not task.title.strip() or task.minutes <= 0:
            raise ValueError("invalid task fields")
        if task.status not in ("open", "active", "done", "cancelled"):
            raise ValueError("invalid status")
        if task.deadline is not None:
            value = datetime.fromisoformat(task.deadline)
            if value.tzinfo is None or value.utcoffset() is None:
                raise ValueError("deadline must contain timezone offset")

    def put(self, task: StoredTask):
        """Idempotent upsert by stable task ID."""
        self._validate(task)
        with self._connection() as db:
            db.execute("""INSERT INTO tasks(id,title,minutes,priority,deadline,status)
              VALUES(?,?,?,?,?,?)
              ON CONFLICT(id) DO UPDATE SET title=excluded.title,
              minutes=excluded.minutes,priority=excluded.priority,
              deadline=excluded.deadline,status=excluded.status""",
              (task.id, task.title, task.minutes, task.priority, task.deadline, task.status))

    def get(self, task_id: str) -> StoredTask | None:
        with self._connection() as db:
            row = db.execute("SELECT * FROM tasks WHERE id=?", (task_id,)).fetchone()
            return StoredTask(**dict(row)) if row else None

    def list(self, status: str | None = None) -> list[StoredTask]:
        if status is not None and status not in ("open", "active", "done", "cancelled"):
            raise ValueError("invalid status")
        with self._connection() as db:
            if status is None:
                rows = db.execute("SELECT * FROM tasks ORDER BY priority DESC,id").fetchall()
            else:
                rows = db.execute("SELECT * FROM tasks WHERE status=? ORDER BY priority DESC,id",
                                  (status,)).fetchall()
            return [StoredTask(**dict(row)) for row in rows]

    def change_status(self, task_id: str, status: str) -> bool:
        if status not in ("open", "active", "done", "cancelled"):
            raise ValueError("invalid status")
        with self._connection() as db:
            result = db.execute("UPDATE tasks SET status=? WHERE id=?", (status, task_id))
            return result.rowcount == 1

"""Transactional plan snapshots with optimistic concurrency and reversible history.

SQLite-only local MVP; no external service or user data in source control.
"""
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
import json
import sqlite3

@dataclass(frozen=True)
class PlanRevision:
    revision: int
    created_at: str
    blocks: tuple[dict, ...]
    reason: str
    restored_from: int | None

class RevisionConflict(ValueError):
    pass

class PlanHistory:
    def __init__(self, path: str | Path):
        self.path = str(path)
        if self.path == ":memory:":
            raise ValueError("persistent database path required")
        Path(self.path).parent.mkdir(parents=True, exist_ok=True)
        with self._connect() as db:
            db.execute("""CREATE TABLE IF NOT EXISTS plan_revisions(
                plan_id TEXT NOT NULL,
                revision INTEGER NOT NULL,
                created_at TEXT NOT NULL,
                blocks_json TEXT NOT NULL,
                reason TEXT NOT NULL,
                restored_from INTEGER,
                PRIMARY KEY(plan_id, revision)
            )""")

    def _connect(self):
        db = sqlite3.connect(self.path, timeout=10)
        db.execute("PRAGMA busy_timeout=10000")
        return db

    @staticmethod
    def _validate_blocks(blocks):
        if not isinstance(blocks, (list, tuple)):
            raise ValueError("blocks must be a sequence")
        ids = set()
        intervals = []
        for block in blocks:
            if not isinstance(block, dict) or set(block) != {"task_id", "start", "end"}:
                raise ValueError("invalid block")
            task_id = block["task_id"]
            if not isinstance(task_id, str) or not task_id.strip() or task_id in ids:
                raise ValueError("invalid or duplicate task id")
            ids.add(task_id)
            start = datetime.fromisoformat(block["start"])
            end = datetime.fromisoformat(block["end"])
            if (start.tzinfo is None or end.tzinfo is None or
                    start.utcoffset() is None or end.utcoffset() is None or end <= start):
                raise ValueError("invalid block interval")
            intervals.append((start.astimezone(timezone.utc), end.astimezone(timezone.utc)))
        intervals.sort()
        if any(left[1] > right[0] for left, right in zip(intervals, intervals[1:])):
            raise ValueError("overlapping blocks")

    @staticmethod
    def _decode(row):
        if row is None:
            return None
        return PlanRevision(row[0], row[1], tuple(json.loads(row[2])), row[3], row[4])

    def latest(self, plan_id: str):
        with self._connect() as db:
            return self._decode(db.execute(
                "SELECT revision,created_at,blocks_json,reason,restored_from "
                "FROM plan_revisions WHERE plan_id=? ORDER BY revision DESC LIMIT 1",
                (plan_id,)).fetchone())

    def commit(self, plan_id: str, blocks: list[dict], *, expected_revision: int,
               reason: str, restored_from: int | None = None) -> PlanRevision:
        if not plan_id.strip() or not reason.strip() or expected_revision < 0:
            raise ValueError("invalid plan metadata")
        self._validate_blocks(blocks)
        encoded = json.dumps(blocks, ensure_ascii=False, sort_keys=True)
        with self._connect() as db:
            db.execute("BEGIN IMMEDIATE")
            row = db.execute("SELECT COALESCE(MAX(revision),0) FROM plan_revisions WHERE plan_id=?",
                             (plan_id,)).fetchone()
            if row[0] != expected_revision:
                raise RevisionConflict(f"expected revision {expected_revision}, found {row[0]}")
            if restored_from is not None:
                exists = db.execute("SELECT 1 FROM plan_revisions WHERE plan_id=? AND revision=?",
                                    (plan_id, restored_from)).fetchone()
                if not exists:
                    raise ValueError("unknown restoration revision")
            rev = expected_revision + 1
            now = datetime.now(timezone.utc).isoformat()
            db.execute("INSERT INTO plan_revisions VALUES(?,?,?,?,?,?)",
                       (plan_id, rev, now, encoded, reason, restored_from))
            db.commit()
        return PlanRevision(rev, now, tuple(json.loads(encoded)), reason, restored_from)

    def undo(self, plan_id: str, *, expected_revision: int) -> PlanRevision:
        if expected_revision < 2:
            raise ValueError("no previous revision")
        with self._connect() as db:
            row = db.execute("SELECT blocks_json FROM plan_revisions WHERE plan_id=? AND revision=?",
                             (plan_id, expected_revision - 1)).fetchone()
        if row is None:
            raise ValueError("previous revision missing")
        return self.commit(plan_id, json.loads(row[0]), expected_revision=expected_revision,
                           reason="undo", restored_from=expected_revision - 1)

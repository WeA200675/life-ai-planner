"""Offline-capable JSON HTTP API, using only Python's standard library.

Development-only loopback server. Do not expose publicly without TLS,
authentication, rate limiting and a reverse proxy.
"""
from dataclasses import asdict
from math import isfinite
from datetime import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from packages.storage.sqlite_store import TaskStore, StoredTask
from packages.storage.plan_history import PlanHistory, RevisionConflict
from packages.scheduler import Task, Block, schedule

MAX_BODY = 65536

def build_handler(store):
    history = PlanHistory(store.path)
    class Handler(BaseHTTPRequestHandler):
        def _json(self, status, payload):
            data = json.dumps(payload, ensure_ascii=False).encode("utf-8")
            self.send_response(status)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.send_header("Content-Length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def _body(self):
            # Only a single JSON media type and a single length are supported.
            # Reject ambiguous framing before reading or mutating the store.
            if self.headers.get("Content-Type", "").split(";", 1)[0].strip().lower() != "application/json":
                raise ValueError("Content-Type must be application/json")
            if self.headers.get("Transfer-Encoding") is not None:
                raise ValueError("Transfer-Encoding is not supported")
            if len(self.headers.get_all("Content-Length", [])) != 1:
                raise ValueError("exactly one Content-Length is required")
            raw_size = self.headers.get("Content-Length", "0")
            if not raw_size.isdecimal():
                raise ValueError("invalid Content-Length")
            size = int(raw_size)
            if not 0 < size <= MAX_BODY:
                raise ValueError("invalid request size")
            raw = self.rfile.read(size)
            if len(raw) != size:
                raise ValueError("incomplete request body")
            def unique_object(pairs):
                result = {}
                for key, value in pairs:
                    if key in result:
                        raise ValueError("duplicate JSON key")
                    result[key] = value
                return result
            def reject_nonfinite(token):
                raise ValueError("non-finite JSON number: " + token)
            value = json.loads(raw, object_pairs_hook=unique_object,
                               parse_constant=reject_nonfinite)
            if not isinstance(value, dict):
                raise ValueError("expected JSON object")
            return value

        def do_GET(self):
            if self.path == "/health":
                return self._json(200, {"status": "ok"})
            if self.path == "/tasks":
                return self._json(200, {"tasks": [asdict(t) for t in store.list()]})
            if self.path.startswith("/plans/") and self.path.endswith("/latest"):
                plan_id = self.path[len("/plans/"):-len("/latest")]
                if not plan_id or "/" in plan_id:
                    return self._json(404, {"error": "not found"})
                latest = history.latest(plan_id)
                return self._json(200, {"plan": asdict(latest) if latest else None})
            return self._json(404, {"error": "not found"})

        def do_POST(self):
            try:
                body = self._body()
                if self.path.startswith("/plans/") and (self.path.endswith("/commit") or self.path.endswith("/undo")):
                    is_undo = self.path.endswith("/undo")
                    suffix = "/undo" if is_undo else "/commit"
                    plan_id = self.path[len("/plans/"):-len(suffix)]
                    if not plan_id or "/" in plan_id or len(plan_id) > 128:
                        raise ValueError("invalid plan id")
                    allowed = {"expected_revision"} if is_undo else {"expected_revision", "reason", "blocks"}
                    if set(body) != allowed or type(body["expected_revision"]) is not int:
                        raise ValueError("invalid revision payload")
                    if is_undo:
                        rev = history.undo(plan_id, expected_revision=body["expected_revision"])
                    else:
                        if type(body["reason"]) is not str or not isinstance(body["blocks"], list):
                            raise ValueError("invalid plan payload")
                        rev = history.commit(plan_id, body["blocks"],
                                             expected_revision=body["expected_revision"],
                                             reason=body["reason"])
                    return self._json(200, {"plan": asdict(rev)})
                if self.path == "/tasks":
                    if set(body) - {"id", "title", "minutes", "priority", "deadline", "status"}:
                        raise ValueError("unexpected task fields")
                    if type(body.get("id")) is not str or type(body.get("title")) is not str or type(body.get("minutes")) is not int or type(body.get("priority", 0)) is not int:
                        raise ValueError("invalid task field types")
                    if body.get("deadline") is not None and type(body["deadline"]) is not str:
                        raise ValueError("invalid deadline type")
                    if type(body.get("status", "open")) is not str:
                        raise ValueError("invalid status type")
                    task = StoredTask(**body)
                    store.put(task)
                    return self._json(200, {"task": asdict(task)})
                if self.path == "/plan":
                    start = datetime.fromisoformat(body["start"])
                    end = datetime.fromisoformat(body["end"])
                    if set(body) - {"start", "end", "buffer_ratio", "fixed"}:
                        raise ValueError("unexpected plan fields")
                    ratio = body.get("buffer_ratio", 0.30)
                    if type(ratio) not in (int, float) or not isfinite(ratio) or not 0 <= ratio < 1:
                        raise ValueError("invalid buffer ratio")
                    raw_fixed = body.get("fixed", [])
                    if not isinstance(raw_fixed, list) or len(raw_fixed) > 500:
                        raise ValueError("invalid fixed blocks")
                    fixed = []
                    for b in raw_fixed:
                        if not isinstance(b, dict) or set(b) != {"task_id", "start", "end"} or type(b["task_id"]) is not str or not b["task_id"]:
                            raise ValueError("invalid fixed block")
                        fixed.append(Block(b["task_id"], datetime.fromisoformat(b["start"]), datetime.fromisoformat(b["end"])))
                    tasks = [Task(t.id, t.title, t.minutes, t.priority,
                                  datetime.fromisoformat(t.deadline) if t.deadline else None)
                             for t in store.list("open")]
                    result = schedule(start, end, tasks, fixed,
                                      ratio)
                    return self._json(200, {
                        "blocks": [{"task_id": b.task_id, "start": b.start.isoformat(),
                                    "end": b.end.isoformat()} for b in result.blocks],
                        "deferred": result.deferred, "conflicts": result.conflicts,
                        "capacity_minutes": result.capacity_minutes,
                        "budget_minutes": result.budget_minutes,
                        "reserved_minutes": result.reserved_minutes})
                return self._json(404, {"error": "not found"})
            except RevisionConflict as exc:
                return self._json(409, {"error": str(exc)})
            except (ValueError, TypeError, KeyError, UnicodeError, json.JSONDecodeError) as exc:
                return self._json(400, {"error": str(exc)})

    return Handler

def main():
    path = os.environ.get("PLANNER_DB", "./data/planner.sqlite")
    host = os.environ.get("PLANNER_HOST", "127.0.0.1")
    if host not in ("127.0.0.1", "::1", "localhost"):
        raise ValueError("public binding disabled until authentication is implemented")
    server = ThreadingHTTPServer((host, int(os.environ.get("PLANNER_PORT", "8788"))),
                                 build_handler(TaskStore(path)))
    server.serve_forever()

if __name__ == "__main__":
    main()

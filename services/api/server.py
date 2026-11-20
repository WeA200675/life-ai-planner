"""Offline-capable JSON HTTP API, using only Python's standard library.

Development-only loopback server. Do not expose publicly without TLS,
authentication, rate limiting and a reverse proxy.
"""
from dataclasses import asdict
from datetime import datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
import json
import os
from packages.storage.sqlite_store import TaskStore, StoredTask
from packages.scheduler import Task, schedule

MAX_BODY = 65536

def build_handler(store):
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
            size = int(self.headers.get("Content-Length", "0"))
            if not 0 < size <= MAX_BODY:
                raise ValueError("invalid request size")
            value = json.loads(self.rfile.read(size))
            if not isinstance(value, dict):
                raise ValueError("expected JSON object")
            return value

        def do_GET(self):
            if self.path == "/health":
                return self._json(200, {"status": "ok"})
            if self.path == "/tasks":
                return self._json(200, {"tasks": [asdict(t) for t in store.list()]})
            return self._json(404, {"error": "not found"})

        def do_POST(self):
            try:
                body = self._body()
                if self.path == "/tasks":
                    if set(body) - {"id", "title", "minutes", "priority", "deadline", "status"}:
                        raise ValueError("unexpected task fields")
                    task = StoredTask(**body)
                    store.put(task)
                    return self._json(200, {"task": asdict(task)})
                if self.path == "/plan":
                    start = datetime.fromisoformat(body["start"])
                    end = datetime.fromisoformat(body["end"])
                    fixed = []
                    tasks = [Task(t.id, t.title, t.minutes, t.priority,
                                  datetime.fromisoformat(t.deadline) if t.deadline else None)
                             for t in store.list("open")]
                    result = schedule(start, end, tasks, fixed,
                                      float(body.get("buffer_ratio", 0.30)))
                    return self._json(200, {
                        "blocks": [{"task_id": b.task_id, "start": b.start.isoformat(),
                                    "end": b.end.isoformat()} for b in result.blocks],
                        "deferred": result.deferred, "conflicts": result.conflicts,
                        "capacity_minutes": result.capacity_minutes,
                        "budget_minutes": result.budget_minutes,
                        "reserved_minutes": result.reserved_minutes})
                return self._json(404, {"error": "not found"})
            except (ValueError, TypeError, KeyError, json.JSONDecodeError) as exc:
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

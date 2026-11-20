import json
import tempfile
import threading
import unittest
from http.server import ThreadingHTTPServer
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError
from packages.storage.sqlite_store import TaskStore
from services.api.server import build_handler

class LocalApiTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        store = TaskStore(Path(self.tmp.name) / "test.sqlite")
        self.httpd = ThreadingHTTPServer(("127.0.0.1", 0), build_handler(store))
        thread = threading.Thread(target=self.httpd.serve_forever, daemon=True)
        thread.start()
        self.addCleanup(self.httpd.server_close)
        self.addCleanup(self.httpd.shutdown)
        self.base = "http://127.0.0.1:" + str(self.httpd.server_port)

    def request(self, path, body=None):
        payload = None if body is None else json.dumps(body).encode()
        req = Request(self.base + path, data=payload,
                      headers={"Content-Type": "application/json"})
        try:
            with urlopen(req, timeout=3) as res:
                return res.status, json.load(res)
        except HTTPError as exc:
            return exc.code, json.load(exc)

    def test_health(self):
        self.assertEqual(self.request("/health")[1]["status"], "ok")

    def test_roundtrip_and_plan(self):
        self.assertEqual(self.request("/tasks", {"id": "a", "title": "Write", "minutes": 60})[0], 200)
        self.assertEqual(len(self.request("/tasks")[1]["tasks"]), 1)
        status, plan = self.request("/plan", {
            "start": "2026-11-21T09:00:00+01:00",
            "end": "2026-11-21T12:00:00+01:00"})
        self.assertEqual(status, 200)
        self.assertEqual(plan["blocks"][0]["task_id"], "a")

    def test_bad_input(self):
        self.assertEqual(self.request("/tasks", {"id": "x", "title": "X", "minutes": -2})[0], 400)

    def test_unknown_route(self):
        self.assertEqual(self.request("/missing")[0], 404)

if __name__ == "__main__":
    unittest.main()

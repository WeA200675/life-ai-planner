import json
from datetime import datetime
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

    def test_duplicate_json_keys_rejected_without_mutation(self):
        for payload in (
            b'{"id":"x","id":"y","title":"Example","minutes":30}',
            b'{"id":"x","title":"Example","minutes":30,"extra":{"a":1,"a":2}}',
        ):
            req = Request(self.base + "/tasks", data=payload,
                          headers={"Content-Type": "application/json"})
            with self.assertRaises(HTTPError) as raised:
                urlopen(req, timeout=3)
            self.assertEqual(raised.exception.code, 400)
        self.assertEqual(self.request("/tasks")[1]["tasks"], [])
        self.assertEqual(self.request("/tasks", {"id": "ok", "title": "Example", "minutes": 30})[0], 200)

    def test_nonfinite_json_numbers_rejected_without_mutation(self):
        # Python's JSON parser accepts these non-standard tokens by default.
        for token in (b"NaN", b"Infinity", b"-Infinity"):
            payload = b'{"id":"unsafe","title":"Example","minutes":30,"extra":' + token + b'}'
            req = Request(self.base + "/tasks", data=payload,
                          headers={"Content-Type": "application/json"})
            with self.assertRaises(HTTPError) as raised:
                urlopen(req, timeout=3)
            self.assertEqual(raised.exception.code, 400)
        self.assertEqual(self.request("/tasks")[1]["tasks"], [])
        self.assertEqual(self.request("/tasks", {"id": "safe", "title": "Example", "minutes": 30})[0], 200)

    def test_request_framing_rejected_without_mutation(self):
        import http.client
        valid = b'{"id":"framed","title":"Example","minutes":30}'
        for headers in (
            {"Content-Type": "text/plain"},
            {"Content-Type": "application/json", "Transfer-Encoding": "chunked"},
        ):
            connection = http.client.HTTPConnection("127.0.0.1", self.httpd.server_port, timeout=3)
            try:
                connection.request("POST", "/tasks", body=valid, headers=headers)
                response = connection.getresponse()
                self.assertEqual(response.status, 400)
                response.read()
            finally:
                connection.close()
        connection = http.client.HTTPConnection("127.0.0.1", self.httpd.server_port, timeout=3)
        try:
            connection.putrequest("POST", "/tasks")
            connection.putheader("Content-Type", "application/json")
            connection.putheader("Content-Length", str(len(valid)))
            connection.putheader("Content-Length", str(len(valid)))
            connection.endheaders(valid)
            response = connection.getresponse()
            self.assertEqual(response.status, 400)
            response.read()
        finally:
            connection.close()
        self.assertEqual(self.request("/tasks")[1]["tasks"], [])
        self.assertEqual(self.request("/tasks", {"id": "valid", "title": "Example", "minutes": 30})[0], 200)

    def test_invalid_utf8_returns_400_and_preserves_store(self):
        for payload in (b'{"id":"bad","title":"\xff","minutes":30}',
                        b'{"id":"bad","title":"\xc3","minutes":30}'):
            req = Request(self.base + "/tasks", data=payload,
                          headers={"Content-Type": "application/json"})
            with self.assertRaises(HTTPError) as raised:
                urlopen(req, timeout=3)
            self.assertEqual(raised.exception.code, 400)
        self.assertEqual(self.request("/tasks")[1]["tasks"], [])
        self.assertEqual(self.request("/tasks", {"id": "ok", "title": "Valid", "minutes": 30})[0], 200)

    def test_unknown_route(self):
        self.assertEqual(self.request("/missing")[0], 404)

    def test_rejects_bool_minutes_and_bad_ratio(self):
        self.assertEqual(self.request("/tasks", {"id": "bad", "title": "Bad", "minutes": True})[0], 400)
        self.assertEqual(self.request("/plan", {"start": "2026-11-21T09:00:00+01:00",
                         "end": "2026-11-21T12:00:00+01:00", "buffer_ratio": True})[0], 400)
        self.assertEqual(self.request("/plan", {"start": "2026-11-21T09:00:00+01:00",
                         "end": "2026-11-21T12:00:00+01:00", "buffer_ratio": 1e309})[0], 400)

    def test_fixed_blocks_are_immutable(self):
        self.request("/tasks", {"id": "a", "title": "Write", "minutes": 60})
        status, result = self.request("/plan", {
            "start": "2026-11-21T09:00:00+01:00",
            "end": "2026-11-21T12:00:00+01:00",
            "fixed": [{"task_id": "meeting", "start": "2026-11-21T09:00:00+01:00",
                       "end": "2026-11-21T10:00:00+01:00"}]})
        self.assertEqual(status, 200)
        self.assertEqual(result["blocks"][0]["task_id"], "meeting")
        # The scheduler serializes UTC instants; offsets may differ while the instant is identical.
        self.assertEqual(datetime.fromisoformat(result["blocks"][1]["start"]),
                         datetime.fromisoformat("2026-11-21T10:00:00+01:00"))

    def test_overlapping_fixed_blocks_rejected(self):
        status, _ = self.request("/plan", {
            "start": "2026-11-21T09:00:00+01:00",
            "end": "2026-11-21T12:00:00+01:00",
            "fixed": [
                {"task_id": "a", "start": "2026-11-21T09:00:00+01:00", "end": "2026-11-21T11:00:00+01:00"},
                {"task_id": "b", "start": "2026-11-21T10:00:00+01:00", "end": "2026-11-21T12:00:00+01:00"}]})
        self.assertEqual(status, 400)

if __name__ == "__main__":
    unittest.main()

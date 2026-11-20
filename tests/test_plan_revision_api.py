"""HTTP regression coverage for persisted plan revisions and conflict handling."""
from tests.test_local_api import LocalApiTests

class PlanRevisionApiTests(LocalApiTests):
    def test_commit_latest_and_undo(self):
        a = {"task_id": "a", "start": "2026-11-21T09:00:00+01:00",
             "end": "2026-11-21T10:00:00+01:00"}
        b = {"task_id": "b", "start": "2026-11-21T10:00:00+01:00",
             "end": "2026-11-21T11:00:00+01:00"}
        status, first = self.request("/plans/day1/commit", {
            "expected_revision": 0, "reason": "initial", "blocks": [a]})
        self.assertEqual(status, 200)
        self.assertEqual(first["plan"]["revision"], 1)
        status, second = self.request("/plans/day1/commit", {
            "expected_revision": 1, "reason": "replan", "blocks": [b]})
        self.assertEqual(status, 200)
        self.assertEqual(second["plan"]["revision"], 2)
        status, undone = self.request("/plans/day1/undo", {"expected_revision": 2})
        self.assertEqual(status, 200)
        self.assertEqual(undone["plan"]["revision"], 3)
        self.assertEqual(undone["plan"]["blocks"][0]["task_id"], "a")
        self.assertEqual(self.request("/plans/day1/latest")[1]["plan"]["revision"], 3)

    def test_stale_revision_returns_conflict(self):
        self.request("/plans/day1/commit", {
            "expected_revision": 0, "reason": "initial", "blocks": []})
        status, _ = self.request("/plans/day1/commit", {
            "expected_revision": 0, "reason": "stale", "blocks": []})
        self.assertEqual(status, 409)

    def test_invalid_revision_and_blocks(self):
        self.assertEqual(self.request("/plans/day1/commit", {
            "expected_revision": True, "reason": "bad", "blocks": []})[0], 400)
        self.assertEqual(self.request("/plans/day1/commit", {
            "expected_revision": 0, "reason": "bad", "blocks": [{"task_id": "x"}]})[0], 400)

    def test_missing_plan(self):
        self.assertIsNone(self.request("/plans/missing/latest")[1]["plan"])

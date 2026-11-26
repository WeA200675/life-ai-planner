"""Guard release artifact publication against accidental CI policy regressions.

These static checks supplement, but never replace, a real GitHub Actions run.
"""
from pathlib import Path
import re
import unittest


WORKFLOW = Path(__file__).resolve().parents[1] / ".github" / "workflows" / "release-acceptance.yml"


def _step_block(source: str, name: str) -> str:
    marker = f"      - name: {name}\n"
    if source.count(marker) != 1:
        raise AssertionError(f"Expected exactly one workflow step: {name}")
    tail = source.split(marker, 1)[1]
    return tail.split("\n      - name: ", 1)[0]


class ReleaseWorkflowPolicyTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.source = WORKFLOW.read_text(encoding="utf-8")

    def test_inflight_release_runs_are_not_cancelled_by_new_pushes(self):
        # A later commit must not destroy the earlier SHA's CI evidence.
        self.assertRegex(self.source, r"(?m)^concurrency:\s*$")
        self.assertRegex(self.source, r"(?m)^  cancel-in-progress: false\s*$")
        self.assertNotRegex(self.source, r"(?m)^  cancel-in-progress: true\s*$")

    def test_publish_is_gated_on_success(self):
        step = _step_block(self.source, "Publish verified release candidate and digest")
        self.assertIn("        if: ${{ success() && vars.ANDROID_RELEASE_CERT_SHA256 != '' }}\n", step)
        self.assertIn("if-no-files-found: error", step)
        self.assertIn("app-release.apk.sha256", step)
        self.assertIn("app-release.apk\n", step)

    def test_release_build_verifies_integrity_and_hash(self):
        step = _step_block(self.source, "Build release-mode candidate (signing status unverified)")
        for requirement in ("flutter build apk --release", 'test -s "$apk"', 'unzip -t "$apk"', 'sha256sum "$apk"'):
            with self.subTest(requirement=requirement):
                self.assertIn(requirement, step)

    def test_signing_gate_is_fail_closed(self):
        step = _step_block(self.source, "Inspect candidate signing certificate")
        for requirement in (
            "apksigner", "verify --verbose --print-certs", "ANDROID_RELEASE_CERT_SHA256",
            "EXPECTED_RELEASE_CERT_SHA256", 'if [ -z "$expected" ]',
            'if [ "$signer_count" -ne 1 ]', 'if [ "$actual" != "$expected" ]',
        ):
            with self.subTest(requirement=requirement):
                self.assertIn(requirement, step)
        self.assertGreaterEqual(step.count("exit 1"), 4)

    def test_backend_and_flutter_tests_precede_release(self):
        self.assertRegex(self.source, r"(?m)^    needs: backend-tests$")
        for step in ("Run repository regression tests and retain evidence", "Flutter tests", "Inspect candidate signing certificate"):
            self.assertIn(f"      - name: {step}\n", self.source)
        self.assertLess(self.source.index("- name: Flutter tests"), self.source.index("- name: Build release-mode candidate"))
        self.assertLess(self.source.index("- name: Inspect candidate signing certificate"), self.source.index("- name: Publish verified release candidate"))

    def test_debug_apk_fallback_is_separate_from_release(self):
        debug_job = self.source.split("\n  debug-test-apk:\n", 1)[1].split("\n  android-release:\n", 1)[0]
        self.assertNotRegex(debug_job, r"(?m)^    needs:")
        self.assertNotIn("continue-on-error:", debug_job)
        build = _step_block(debug_job, "Build isolated debug smoke-test APK")
        publish = _step_block(debug_job, "Publish UNVERIFIED debug device-test APK and digest")
        for requirement in ("flutter build apk --debug", '-s "$apk"', 'unzip -t "$apk"',
                            "sha256sum app-debug.apk", "sha256sum --check app-debug.apk.sha256"):
            self.assertIn(requirement, build)
        self.assertIn("life-ai-planner-debug-test-only", publish)
        self.assertIn("app-debug.apk.sha256", publish)
        self.assertIn("if-no-files-found: error", publish)
        self.assertNotIn("app-release.apk", publish)
        self.assertNotRegex(publish, r"(?m)^        if:")
        self.assertLess(debug_job.index("- name: Build isolated debug"), debug_job.index("- name: Publish UNVERIFIED"))
        release = _step_block(self.source, "Publish verified release candidate and digest")
        self.assertNotIn("app-debug.apk", release)

    def test_diagnostics_survive_failure_without_publishing_apk(self):
        for name in ("Upload backend test evidence", "Upload Flutter test evidence", "Upload release build diagnostics", "Upload signing diagnostic evidence"):
            step = _step_block(self.source, name)
            self.assertRegex(step, r"(?m)^        if: always\(\)\s*$")
            self.assertNotIn("app-release.apk\n", step)


if __name__ == "__main__":
    unittest.main()

# Delivery acceleration: vertical slices and quality gates

Status: active execution policy; not a claim of M1–M4 acceptance.

## Single integration owner
- Only one writer integrates into `main`. Other runs use distinct feature branches and PRs.
- Before **every write**, fetch target branch HEAD and the destination file's blob SHA. If HEAD moved, reread the changed files and rebase/reconcile; never overwrite a concurrent change.
- Existing open PRs take precedence over duplicate implementation. Inspect their changed paths, CI and review state before starting overlapping work.
- Do not open duplicate issues for tasks already tracked by an open PR or this plan.

## Critical path, ordered by user value
1. **Gate A: Android offline end-to-end MVP** — create/edit/reopen task in SQLite; preview a day with protected fixed events and 70/30 reserve; empty/error/loading states; deterministic widget and persistence tests; installable APK.
2. **Gate B: Safe replanning** — integrate the existing read-only `replanOfflineDay` and the pending SQLite adapter PR into Android UI; explicit confirm; versioned plan snapshot and undo; no implicit calendar writes; test restart and conflicts.
3. **Gate C: Input and execution** — text always works; voice feature-detection, permission/denial/no-network fallbacks; notifications and Android background restrictions; test on supported device.
4. **Gate D: Calibration** — real-vs-estimated durations, 14-day bounded calibration, idempotent night consolidation, reproducible fixture tests.
5. **Gate E: Optional extensions** — dashboard, reflection, optional Health Connect opt-in, optional backend; offline core must remain available.
6. **Gate F: Release** — reproducible release build, backup/restore and migration/rollback drills, E2E and manual Android acceptance, privacy review.

## Definition of done for every slice
- User-visible behavior plus deterministic automated test for happy path, invalid input, persistence/restart and fallback.
- CI results linked to **exact commit SHA**; queued CI is not success.
- No real personal/health data, credentials or destructive deploy.
- Benchmark only when measured with fixed fixtures; record baseline, environment, repetitions and regression threshold. Do not claim speedups without numbers.
- `docs/STATUS.md`: source HEAD, changed SHAs, CI links/results, blockers, next gate and remaining device tests.
- A failed gate blocks merging, not independent branch work. Preserve last known green APK as fallback.

## Performance and agility budget
- Prioritize **complete vertical functionality** over serial one-line input hardening unless the defect is exploitable or blocks the user journey.
- Batch independent tests in CI; use path filters so Flutter-only changes do not rebuild unrelated Python components, but run cross-component contract tests at integration.
- Measure scheduler latency with deterministic synthetic task sets (small/medium/large); set an explicit regression budget only after baseline data exists.
- Avoid speculative caching or parallel writes to SQLite; correctness and predictable offline behavior first.
- Keep PRs reviewable and integration frequency high: one user-visible slice per PR, not a monolithic untestable merge.

## Immediate execution
1. Check PR #1 and its green CI at the exact PR head; review and integrate safely before duplicating its SQLite adapter.
2. Implement Gate B Android UI confirmation + undo with widget tests on a dedicated branch.
3. Generate a fresh APK and perform manual Android acceptance; record actual outcomes.

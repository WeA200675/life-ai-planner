# Performance master plan P0–P7

Status: **planned, not measured or accepted**. Performance targets below are proposed engineering gates, not existing measurements. This plan complements [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) and [DELIVERY_ACCELERATION.md](DELIVERY_ACCELERATION.md). The Android offline user journey remains the primary delivery priority.

## Non-negotiable invariants
- No lost or silently altered tasks, protected calendar blocks, deadlines, or plan history.
- Deterministic output, 70/30 reserve, timezone/DST correctness and reproducible offline fallback.
- Privacy: synthetic fixtures only; health/biometric features opt-in; no network requirement for core scheduling.
- A green test on an older SHA is not evidence for the current commit. No performance claim without baseline and post-change data on the same environment.

## P0 — Instrumentation and reproducible baseline (1–2 focused development days)
Deliverables: checked-in Python scheduler benchmark script (warmup, repeated runs, median/p95), synthetic fixed-seed workloads with 100/1,000/10,000 tasks, and CI smoke benchmark. Flutter profile-mode Android trace instructions, SQLite EXPLAIN QUERY PLAN captures and device metadata. Keep benchmarks separate from correctness assertions. Gate: repeatable baseline with environment, SHA, task count, gaps and iterations documented.

## P1 — Scheduler algorithm and memory (2–4 days)
Profile hot paths first. Evaluate indexed free-interval lookup, deadline-pruned gap traversal and precomputed UTC/minute values; choose only changes preserving deterministic ordering. Compare worst-case fragmentation and dense deadlines. Gate: parity tests vs reference scheduler, DST/overlap/70:30 tests, median/p95 on P0 workloads; reject regressions >10% unless explicitly justified. Proposed stretch goal: >=30% reduction in p95 on a representative fragmented workload, **not guaranteed**.

## P2 — SQLite offline storage (2–3 days)
Audit indexes against actual queries; measure EXPLAIN, transaction batching, WAL/checkpoint behavior and startup/reopen. Never assume WAL is universally safe (platform/filesystem constraints). Gate: persistence/restart/migration/rollback tests and no lost data under interrupted writes; record query latency and database size.

## P3 — Flutter Android rendering and responsiveness (3–5 days)
Profile build/raster frame timing, cold start, list scrolling, DB-to-UI hops and memory on real Android device in profile mode. Use lazy lists, scoped state changes and cancellable background computation only where traces justify them. Preserve reduced-motion/text fallback. Proposed device targets: p95 frame time <=16.7 ms at 60 Hz and user-action feedback <=100 ms on the agreed test device; report device and real observed metrics before accepting.

## P4 — Replanning vertical slice (3–5 days)
Review and integrate existing PR #1 before duplicating its SQLite adapter. Complete Android preview -> explicit confirmation -> versioned snapshot -> undo, with protected fixed blocks and conflict explanations. Profile incremental vs full replanning and debounce bursts of events. Gate: deterministic widget/integration tests, restart/undo and concurrency tests, no calendar mutation without consent, Android APK artifact.

## P5 — Voice/AI/background efficiency (3–5 days)
Text fallback is mandatory; feature-detect offline STT, permissions and network. Bounded queues, cancellation, backpressure and battery-aware work scheduling. No continuous heavy background inference by default. Gate: offline/permission-denied tests, idle and active battery profiling on real device, no loss of tasks.

## P6 — Stress, reliability and CI guardrails (2–4 days)
Synthetic soak runs, 10k-task imports, repeated replanning, SQLite interruption, restart and memory trend checks. Establish thresholds from baseline; fail CI only on stable dedicated runners or robust relative comparisons, not noisy shared-host wall time. Gate: reproducible stress report and documented fallback/rollback.

## P7 — Release acceptance (2–3 days)
Reproducible Android release artifact, checksum, manual real-device acceptance, offline/airplane-mode scenario, battery and startup measurements, backup/restore and migration drills, privacy/security review. Gate: signed acceptance matrix with actual evidence; until then M1–M4 and P0–P7 are **not complete**.

## Execution policy
1. One integration owner; feature branches for independent work; before every write check HEAD and destination blob SHA; reread/reconcile if moved.
2. Prioritize P0 instrumentation and the P4 Android end-to-end user journey in parallel only when paths do not overlap. Do not block shipping on speculative micro-optimizations.
3. Every PR must carry code, deterministic regression tests, before/after measurements where applicable, CI run URLs bound to the commit SHA, and a rollback note.
4. Record results, blockers and next concrete task in [STATUS.md](STATUS.md). Never manufacture timings, benchmarks or device acceptance.
5. Avoid an automatic merge when CI, device safety, data migration or PR conflict remains uncertain.

## Suggested delivery cadence
- Daily integration of one **complete, testable user-visible vertical slice**, not isolated defensive patches.
- P0–P7 time budgets are estimates of focused engineering effort; do not equate them with autonomous run elapsed time.
- A fallback is the last known green APK plus a reversible plan snapshot; never delete live data to speed up processing.

"""Compare two saved scheduler benchmark JSON artifacts.

Run: python -m tools.compare_scheduler_benchmarks baseline.json candidate.json
This tool never infers a performance improvement from different workload shapes.
"""
from __future__ import annotations

import argparse
import json
import math
from pathlib import Path


class IncompatibleBenchmark(ValueError):
    """Benchmark results cannot be compared safely."""


def _validated(raw: object) -> dict[int, dict]:
    if not isinstance(raw, dict) or raw.get("schema_version") != 1:
        raise IncompatibleBenchmark("unsupported benchmark schema")
    results = raw.get("results")
    if not isinstance(results, list) or not results:
        raise IncompatibleBenchmark("missing benchmark results")
    indexed = {}
    for item in results:
        if not isinstance(item, dict):
            raise IncompatibleBenchmark("invalid result")
        count = item.get("tasks")
        if type(count) is not int or count < 0 or count in indexed:
            raise IncompatibleBenchmark("duplicate or invalid task count")
        for field in ("fixed_blocks", "seed", "warmup", "repeats",
                      "scheduled", "deferred", "capacity_minutes", "budget_minutes"):
            if type(item.get(field)) is not int or item[field] < 0:
                raise IncompatibleBenchmark(f"invalid {field}")
        for field in ("median_ms", "p95_ms", "min_ms", "max_ms"):
            value = item.get(field)
            if type(value) not in (int, float) or not math.isfinite(value) or value < 0:
                raise IncompatibleBenchmark(f"invalid {field}")
        if item["scheduled"] + item["deferred"] != count:
            raise IncompatibleBenchmark("inconsistent scheduled/deferred totals")
        if not item["min_ms"] <= item["max_ms"]:
            raise IncompatibleBenchmark("invalid timing range")
        indexed[count] = item
    return indexed


def compare(baseline: dict, candidate: dict, *, regression_limit: float = .10) -> dict:
    if not math.isfinite(regression_limit) or regression_limit < 0:
        raise ValueError("regression_limit must be finite and nonnegative")
    old, new = _validated(baseline), _validated(candidate)
    if set(old) != set(new):
        raise IncompatibleBenchmark("task sizes differ")
    if baseline.get("python") != candidate.get("python") or baseline.get("platform") != candidate.get("platform"):
        raise IncompatibleBenchmark("Python/platform differ; use matched environments")
    rows = []
    for count in sorted(old):
        a, b = old[count], new[count]
        for field in ("tasks", "fixed_blocks", "seed", "warmup", "repeats",
                      "scheduled", "deferred", "capacity_minutes", "budget_minutes"):
            if a[field] != b[field]:
                raise IncompatibleBenchmark(f"{count}: workload or output differs: {field}")
        if a["p95_ms"] == 0:
            raise IncompatibleBenchmark("zero baseline p95 cannot be compared")
        delta = (b["p95_ms"] / a["p95_ms"] - 1) * 100
        rows.append({
            "tasks": count,
            "baseline_p95_ms": a["p95_ms"],
            "candidate_p95_ms": b["p95_ms"],
            "change_percent": round(delta, 2),
            "regression": delta > regression_limit * 100,
        })
    return {"comparable": True, "regression_limit_percent": regression_limit * 100,
            "regression_detected": any(x["regression"] for x in rows),
            "results": rows,
            "note": "Shared CI runners are noisy; review repeated measurements before gating merges."}


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("baseline", type=Path)
    parser.add_argument("candidate", type=Path)
    parser.add_argument("--regression-limit", type=float, default=.10)
    parser.add_argument("--fail-on-regression", action="store_true")
    args = parser.parse_args(argv)
    try:
        baseline = json.loads(args.baseline.read_text(encoding="utf-8"))
        candidate = json.loads(args.candidate.read_text(encoding="utf-8"))
        report = compare(baseline, candidate, regression_limit=args.regression_limit)
    except (ValueError, OSError) as exc:
        parser.error(str(exc))
    print(json.dumps(report, indent=2, sort_keys=True))
    return 1 if args.fail_on_regression and report["regression_detected"] else 0


if __name__ == "__main__":
    raise SystemExit(main())

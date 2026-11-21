"""Reproducible synthetic scheduler benchmarks; never uses personal data.

Run: python -m tools.benchmark_scheduler --sizes 100 1000 10000 --repeats 7
Wall-clock numbers are environment-specific and are not CI pass/fail thresholds.
"""
from __future__ import annotations

import argparse
import json
import platform
import random
import statistics
import sys
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path

from packages.scheduler.engine import Block, Task, schedule

START = datetime(2026, 11, 20, 8, tzinfo=timezone.utc)


def fixture(count: int, *, seed: int = 42, fixed_count: int = 12):
    """Stable, valid workload; independent of process hash randomization."""
    if count < 0 or fixed_count < 0 or fixed_count > 96:
        raise ValueError("invalid workload dimensions")
    rng = random.Random(seed)
    end = START + timedelta(hours=24)
    fixed = [
        Block(f"fixed-{i}", START + timedelta(minutes=10 * i),
              START + timedelta(minutes=10 * i + 5))
        for i in range(fixed_count)
    ]
    tasks = [
        Task(f"task-{i:06d}", f"Synthetic {i}", rng.randint(1, 90),
             rng.randint(0, 10),
             end - timedelta(minutes=rng.randint(0, 180)) if i % 3 == 0 else None)
        for i in range(count)
    ]
    return START, end, tasks, fixed


def percentile(values: list[float], fraction: float) -> float:
    if not values or not 0 <= fraction <= 1:
        raise ValueError("nonempty values and fraction in [0, 1] required")
    ordered = sorted(values)
    rank = (len(ordered) - 1) * fraction
    lower = int(rank)
    upper = min(lower + 1, len(ordered) - 1)
    return ordered[lower] + (ordered[upper] - ordered[lower]) * (rank - lower)


def benchmark(count: int, *, seed: int = 42, warmup: int = 2,
              repeats: int = 7, fixed_count: int = 12) -> dict:
    if repeats < 1 or warmup < 0:
        raise ValueError("invalid iteration counts")
    args = fixture(count, seed=seed, fixed_count=fixed_count)
    for _ in range(warmup):
        schedule(*args[:3], fixed=args[3])
    samples = []
    result = None
    for _ in range(repeats):
        begin = time.perf_counter_ns()
        result = schedule(*args[:3], fixed=args[3])
        samples.append((time.perf_counter_ns() - begin) / 1_000_000)
    assert result is not None
    return {
        "tasks": count,
        "fixed_blocks": fixed_count,
        "seed": seed,
        "warmup": warmup,
        "repeats": repeats,
        "median_ms": round(statistics.median(samples), 4),
        "p95_ms": round(percentile(samples, .95), 4),
        "min_ms": round(min(samples), 4),
        "max_ms": round(max(samples), 4),
        "scheduled": len(result.blocks) - fixed_count,
        "deferred": len(result.deferred),
        "capacity_minutes": result.capacity_minutes,
        "budget_minutes": result.budget_minutes,
    }


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sizes", type=int, nargs="+", default=[100, 1000, 10000])
    parser.add_argument("--repeats", type=int, default=7)
    parser.add_argument("--warmup", type=int, default=2)
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--fixed-count", type=int, default=12)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args(argv)
    if any(n < 0 for n in args.sizes):
        parser.error("sizes must be nonnegative")
    try:
        results = [
            benchmark(n, seed=args.seed, repeats=args.repeats,
                      warmup=args.warmup, fixed_count=args.fixed_count)
            for n in args.sizes
        ]
    except ValueError as exc:
        parser.error(str(exc))
    payload = {
        "schema_version": 1,
        "python": sys.version.split()[0],
        "platform": platform.platform(),
        "results": results,
    }
    rendered = json.dumps(payload, indent=2, sort_keys=True) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(rendered, encoding="utf-8")
    print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

"""Pure, deterministic, timezone-aware daily scheduler. No network or LLM required."""
from dataclasses import dataclass
from datetime import datetime, timedelta
from math import floor

@dataclass(frozen=True)
class Task:
    id: str
    title: str
    minutes: int
    priority: int = 0
    deadline: datetime | None = None

@dataclass(frozen=True)
class Block:
    task_id: str
    start: datetime
    end: datetime

@dataclass(frozen=True)
class Plan:
    blocks: tuple[Block, ...]
    deferred: tuple[str, ...]
    conflicts: tuple[str, ...]
    capacity_minutes: int
    budget_minutes: int
    reserved_minutes: int

def schedule(start: datetime, end: datetime, tasks: list[Task],
             fixed: list[Block] | None = None, buffer_ratio: float = 0.30) -> Plan:
    """Place flexible tasks in free gaps without moving fixed blocks.

    The 70/30 limit applies to flexible-task time after fixed commitments.
    Fixed blocks are immutable. Deferred tasks remain explicit, never discarded.
    """
    if start.tzinfo is None or end.tzinfo is None:
        raise ValueError("start/end must be timezone-aware")
    if end <= start or not 0 <= buffer_ratio < 1:
        raise ValueError("invalid window or buffer ratio")
    if any(t.minutes <= 0 or not t.id or not t.title for t in tasks):
        raise ValueError("invalid task")
    if len({t.id for t in tasks}) != len(tasks):
        raise ValueError("duplicate task id")
    fixed = list(fixed or [])
    if any(b.start.tzinfo is None or b.end.tzinfo is None or b.start < start or
           b.end > end or b.end <= b.start for b in fixed):
        raise ValueError("invalid fixed block")
    fixed.sort(key=lambda b: (b.start, b.end))
    if any(a.end > b.start for a, b in zip(fixed, fixed[1:])):
        raise ValueError("overlapping fixed blocks")
    capacity = floor((end - start).total_seconds() / 60)
    occupied = sum(floor((b.end - b.start).total_seconds() / 60) for b in fixed)
    available = max(0, capacity - occupied)
    budget = floor(available * (1 - buffer_ratio))
    gaps = []
    cursor = start
    for block in fixed:
        if cursor < block.start:
            gaps.append([cursor, block.start])
        cursor = block.end
    if cursor < end:
        gaps.append([cursor, end])
    blocks = list(fixed)
    deferred = []
    conflicts = []
    used = 0
    for task in sorted(tasks, key=lambda t: (-t.priority, t.deadline or end, t.id)):
        if used + task.minutes > budget:
            deferred.append(task.id)
            conflicts.append(f"{task.id}: buffer budget exceeded")
            continue
        placed = False
        for gap in gaps:
            finish = gap[0] + timedelta(minutes=task.minutes)
            if finish <= gap[1] and (task.deadline is None or finish <= task.deadline):
                blocks.append(Block(task.id, gap[0], finish))
                gap[0] = finish
                used += task.minutes
                placed = True
                break
        if not placed:
            deferred.append(task.id)
            conflicts.append(f"{task.id}: no feasible time slot")
    return Plan(tuple(sorted(blocks, key=lambda b: (b.start, b.task_id))),
                tuple(deferred), tuple(conflicts), capacity, budget, available - used)

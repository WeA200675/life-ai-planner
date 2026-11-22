/// Deterministic offline-only planning core; mirrors the Python scheduler's
/// priority, 70/30 buffer and immutable fixed-block semantics.
class DayTask {
  const DayTask({required this.id, required this.minutes, this.priority = 0,
    this.deadline});
  final String id;
  final int minutes;
  final int priority;
  final DateTime? deadline;
}

class DayBlock {
  const DayBlock(this.id, this.start, this.end);
  final String id;
  final DateTime start;
  final DateTime end;
}

class DayPlan {
  const DayPlan(this.blocks, this.deferred, this.conflicts,
      this.capacityMinutes, this.budgetMinutes, this.reservedMinutes);
  final List<DayBlock> blocks;
  final List<String> deferred;
  final List<String> conflicts;
  final int capacityMinutes;
  final int budgetMinutes;
  final int reservedMinutes;
}

/// Validate all task records, including records later excluded as completed.
/// Otherwise corrupt completed rows can silently bypass the planner contract.
Set<String> _validateTasks(List<DayTask> tasks) {
  final ids = <String>{};
  for (final task in tasks) {
    if (task.id.trim().isEmpty || task.id != task.id.trim() ||
        task.minutes < 1 || task.minutes > 1440 ||
        task.priority < 0 || task.priority > 10 ||
        !ids.add(task.id)) {
      throw ArgumentError('Invalid or duplicate task');
    }
  }
  return ids;
}

DayPlan planOfflineDay(DateTime start, DateTime end, List<DayTask> tasks,
    {List<DayBlock> fixed = const [], double bufferRatio = 0.30}) {
  if (!start.isBefore(end) || !bufferRatio.isFinite ||
      bufferRatio < 0 || bufferRatio >= 1) {
    throw ArgumentError('Invalid planning window or buffer');
  }
  final ids = _validateTasks(tasks);
  final fixedIds = <String>{};
  for (final block in fixed) {
    if (block.id.trim().isEmpty || block.id != block.id.trim() ||
        !fixedIds.add(block.id) || ids.contains(block.id)) {
      throw ArgumentError('Invalid or duplicate fixed block id');
    }
  }
  final protected = [...fixed]..sort((a, b) => a.start.compareTo(b.start));
  for (var i = 0; i < protected.length; i++) {
    final block = protected[i];
    if (!block.start.isBefore(block.end) ||
        block.start.isBefore(start) || block.end.isAfter(end) ||
        (i > 0 && protected[i - 1].end.isAfter(block.start))) {
      throw ArgumentError('Invalid or overlapping fixed block');
    }
  }
  // DateTime.difference uses elapsed time and remains safe across DST changes.
  // Compute capacity from the actual free gaps, not by subtracting
  // individually truncated appointment durations. For appointments with
  // seconds, truncation per block would overstate free capacity.
  final capacity = end.difference(start).inMinutes;
  final freeDuration = end.difference(start) -
      protected.fold<Duration>(Duration.zero,
          (sum, b) => sum + b.end.difference(b.start));
  final available = freeDuration.inMinutes;
  final budget = (freeDuration.inMicroseconds /
          Duration.microsecondsPerMinute * (1 - bufferRatio)).floor();
  final gaps = <({DateTime start, DateTime end})>[];
  var cursor = start;
  for (final block in protected) {
    if (cursor.isBefore(block.start)) {
      gaps.add((start: cursor, end: block.start));
    }
    cursor = block.end;
  }
  if (cursor.isBefore(end)) gaps.add((start: cursor, end: end));
  final ordered = [...tasks]..sort((a, b) {
    final priority = b.priority.compareTo(a.priority);
    if (priority != 0) return priority;
    final deadline = (a.deadline ?? end).compareTo(b.deadline ?? end);
    return deadline != 0 ? deadline : a.id.compareTo(b.id);
  });
  final blocks = <DayBlock>[...protected];
  final deferred = <String>[];
  final conflicts = <String>[];
  var used = 0;
  for (final task in ordered) {
    if (used + task.minutes > budget) {
      deferred.add(task.id);
      conflicts.add('${task.id}: buffer budget exceeded');
      continue;
    }
    var placed = false;
    for (var i = 0; i < gaps.length; i++) {
      final gap = gaps[i];
      final finish = gap.start.add(Duration(minutes: task.minutes));
      if (!finish.isAfter(gap.end) &&
          (task.deadline == null || !finish.isAfter(task.deadline!))) {
        blocks.add(DayBlock(task.id, gap.start, finish));
        gaps[i] = (start: finish, end: gap.end);
        used += task.minutes;
        placed = true;
        break;
      }
    }
    if (!placed) {
      deferred.add(task.id);
      conflicts.add('${task.id}: no feasible time slot');
    }
  }
  blocks.sort((a, b) {
    final time = a.start.compareTo(b.start);
    return time != 0 ? time : a.id.compareTo(b.id);
  });
  return DayPlan(List.unmodifiable(blocks), List.unmodifiable(deferred),
      List.unmodifiable(conflicts), capacity, budget, available - used);
}


/// Replans the remaining day after an interruption, entirely offline.
///
/// Completed task IDs are excluded, and fixed appointments already in progress
/// remain protected until their original end. Past appointments are ignored.
/// The input collections are never mutated. The caller must persist/confirm a
/// proposed replacement plan separately; this is a read-only preview.
DayPlan replanOfflineDay(
  DateTime now,
  DateTime end,
  List<DayTask> tasks, {
  List<DayBlock> fixed = const [],
  Set<String> completedTaskIds = const {},
  double bufferRatio = 0.30,
}) {
  if (!now.isBefore(end)) {
    throw ArgumentError('Invalid remaining planning window');
  }
  final taskIds = _validateTasks(tasks);
  if (!completedTaskIds.every(taskIds.contains)) {
    throw ArgumentError('Duplicate task or unknown completed task id');
  }
  // Validate the *entire* original set before clipping. Otherwise an
  // invalid/duplicate appointment in the past silently disappears.
  final fixedIds = <String>{};
  final sortedFixed = [...fixed]..sort((a, b) => a.start.compareTo(b.start));
  for (var i = 0; i < sortedFixed.length; i++) {
    final block = sortedFixed[i];
    if (block.id.trim().isEmpty || block.id != block.id.trim() ||
        !fixedIds.add(block.id) || taskIds.contains(block.id) ||
        !block.start.isBefore(block.end) ||
        (i > 0 && sortedFixed[i - 1].end.isAfter(block.start))) {
      throw ArgumentError('Invalid, duplicate or overlapping fixed appointment');
    }
  }
  final remainingFixed = <DayBlock>[
    for (final block in fixed)
      if (block.end.isAfter(now) && block.start.isBefore(end))
        DayBlock(
          block.id,
          block.start.isBefore(now) ? now : block.start,
          block.end.isAfter(end) ? end : block.end,
        ),
  ];
  return planOfflineDay(
    now,
    end,
    [for (final task in tasks) if (!completedTaskIds.contains(task.id)) task],
    fixed: remainingFixed,
    bufferRatio: bufferRatio,
  );
}

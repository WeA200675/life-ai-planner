import 'offline_day_planner.dart';

/// Converts local SQLite rows into a deterministic, read-only planning preview.
/// Older SQLite rows without planning metadata use a provisional 30-minute
/// duration and priority zero. Malformed metadata is rejected, never guessed.
/// No database data is modified.
DayPlan previewLocalTasks(
  DateTime start,
  DateTime end,
  List<Map<String, Object?>> rows, {
  int provisionalMinutes = 30,
  double bufferRatio = 0.30,
}) {
  if (provisionalMinutes <= 0 || provisionalMinutes > 1440) {
    throw ArgumentError.value(provisionalMinutes, 'provisionalMinutes');
  }
  return planOfflineDay(start, end,
      _parseLocalTasks(rows, provisionalMinutes), bufferRatio: bufferRatio);
}

/// Shared strict SQLite-row conversion for both preview and interruption flows.
List<DayTask> _parseLocalTasks(
    List<Map<String, Object?>> rows, int provisionalMinutes) {
  final tasks = <DayTask>[];
  final seenIds = <int>{};
  for (final row in rows) {
    final id = row['id'];
    final done = row['done'];
    if (id is! int || id <= 0 || (done != 0 && done != 1)) {
      throw FormatException('Invalid local task row');
    }
    if (!seenIds.add(id)) {
      throw FormatException('Duplicate local task id');
    }
    if (done == 0) {
      final minutes = row['minutes'] ?? provisionalMinutes;
      final priority = row['priority'] ?? 0;
      if (minutes is! int || minutes <= 0 || minutes > 1440 ||
          priority is! int || priority < 0 || priority > 10) {
        throw FormatException('Invalid local task planning metadata');
      }
      final rawDeadline = row['deadline_utc_ms'];
      DateTime? deadline;
      if (rawDeadline != null) {
        if (rawDeadline is! int || rawDeadline <= 0) {
          throw FormatException('Invalid local task deadline');
        }
        try {
          deadline = DateTime.fromMillisecondsSinceEpoch(rawDeadline, isUtc: true);
        } on ArgumentError {
          throw FormatException('Invalid local task deadline');
        }
      }
      tasks.add(DayTask(
        id: id.toString(), minutes: minutes, priority: priority,
        deadline: deadline,
      ));
    }
  }
  return tasks;
}

/// Read-only replanning of remaining local tasks after an interruption.
/// Completed SQLite rows are excluded by the shared parser. Nothing is saved
/// until the caller explicitly chooses to persist a plan version.
DayPlan replanLocalTasks(
  DateTime now,
  DateTime end,
  List<Map<String, Object?>> rows, {
  List<DayBlock> fixed = const [],
  int provisionalMinutes = 30,
  double bufferRatio = 0.30,
}) {
  if (provisionalMinutes < 1 || provisionalMinutes > 1440) {
    throw ArgumentError.value(provisionalMinutes, 'provisionalMinutes');
  }
  return replanOfflineDay(now, end,
      _parseLocalTasks(rows, provisionalMinutes),
      fixed: fixed, bufferRatio: bufferRatio);
}


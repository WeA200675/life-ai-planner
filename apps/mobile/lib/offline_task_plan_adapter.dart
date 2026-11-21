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
  return planOfflineDay(start, end, tasks, bufferRatio: bufferRatio);
}

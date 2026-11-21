import 'offline_day_planner.dart';

/// Converts local SQLite rows into a deterministic, read-only planning preview.
/// Until task durations are persisted, each open task receives an explicit
/// provisional 30-minute estimate; no database data is modified.
DayPlan previewLocalTasks(
  DateTime start,
  DateTime end,
  List<Map<String, Object?>> rows, {
  int provisionalMinutes = 30,
  double bufferRatio = 0.30,
}) {
  if (provisionalMinutes <= 0) {
    throw ArgumentError.value(provisionalMinutes, 'provisionalMinutes');
  }
  final tasks = <DayTask>[];
  for (final row in rows) {
    final id = row['id'];
    final done = row['done'];
    if (id is! int || id <= 0 || (done != 0 && done != 1)) {
      throw FormatException('Invalid local task row');
    }
    if (done == 0) {
      tasks.add(DayTask(id: id.toString(), minutes: provisionalMinutes));
    }
  }
  return planOfflineDay(start, end, tasks, bufferRatio: bufferRatio);
}

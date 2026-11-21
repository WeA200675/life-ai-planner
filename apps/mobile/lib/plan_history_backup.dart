import 'dart:convert';

import 'package:sqflite/sqflite.dart';

/// Read-only, consistent export of plan history. Does not alter active tasks,
/// plans, or sync state. Import is intentionally not offered until validated.
Future<String> exportPlanHistoryBackup(Database db, {
  int maxSnapshots = 10000,
  int maxBytes = 8 * 1024 * 1024,
}) async {
  if (maxSnapshots < 1 || maxSnapshots > 10000 ||
      maxBytes < 1 || maxBytes > 8 * 1024 * 1024) {
    throw ArgumentError('Invalid backup limits');
  }
  return db.transaction((txn) async {
    final headers = await txn.query('plan_snapshots',
        orderBy: 'id ASC', limit: maxSnapshots + 1);
    if (headers.length > maxSnapshots) {
      throw const FormatException('Plan history exceeds export limit');
    }
    final blocks = await txn.query('plan_snapshot_blocks',
        orderBy: 'snapshot_id ASC, position ASC');
    final known = <int>{};
    final windows = <int, (int, int)>{};
    for (final h in headers) {
      final id = h['id'];
      final start = h['window_start_utc_ms'];
      final end = h['window_end_utc_ms'];
      final created = h['created_utc_ms'];
      final budget = h['budget_minutes'];
      final reserve = h['reserved_minutes'];
      if (id is! int || id <= 0 || !known.add(id) ||
          start is! int || end is! int || start >= end ||
          created is! int || created <= 0 ||
          budget is! int || budget < 0 ||
          reserve is! int || reserve < 0) {
        throw const FormatException('Invalid plan snapshot');
      }
      windows[id] = (start, end);
    }
    final positions = <int, int>{};
    final lastEnd = <int, int>{};
    final taskIds = <int, Set<String>>{};
    for (final b in blocks) {
      final id = b['snapshot_id'];
      final position = b['position'];
      final taskId = b['task_id'];
      final start = b['start_utc_ms'];
      final end = b['end_utc_ms'];
      if (id is! int || !known.contains(id) ||
          position is! int || position != (positions[id] ?? 0) ||
          taskId is! String || taskId.trim().isEmpty ||
          !(taskIds.putIfAbsent(id, () => <String>{})).add(taskId) ||
          start is! int || end is! int || start >= end ||
          start < windows[id]!.$1 || end > windows[id]!.$2 ||
          (lastEnd[id] != null && start < lastEnd[id]!)) {
        throw const FormatException('Invalid plan history block');
      }
      positions[id] = position + 1;
      lastEnd[id] = end;
    }
    final output = const JsonEncoder.withIndent('  ').convert({
      'format': 'life-ai-planner-plan-history',
      'schema_version': 1,
      'snapshots': headers,
      'blocks': blocks,
    });
    if (output.length > maxBytes) {
      throw const FormatException('Plan history backup exceeds size limit');
    }
    return output;
  });
}

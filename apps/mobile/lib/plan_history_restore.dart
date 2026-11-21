import 'dart:convert';

import 'package:sqflite/sqflite.dart';

/// Validated offline history archive. No existing database is modified while
/// parsing. Restoring is permitted only into an empty history store.
class PlanHistoryArchive {
  const PlanHistoryArchive(this.snapshots, this.blocks);
  final List<Map<String, Object?>> snapshots;
  final List<Map<String, Object?>> blocks;
}

const _headerKeys = {
  'id', 'created_utc_ms', 'window_start_utc_ms', 'window_end_utc_ms',
  'budget_minutes', 'reserved_minutes',
};
const _blockKeys = {
  'snapshot_id', 'position', 'task_id', 'start_utc_ms', 'end_utc_ms',
};

Map<String, Object?> _record(Object? value, Set<String> fields) {
  if (value is! Map<String, dynamic> ||
      value.keys.toSet().difference(fields).isNotEmpty ||
      value.keys.length != fields.length ||
      !fields.every(value.containsKey)) {
    throw const FormatException('Unexpected plan history fields');
  }
  return Map.unmodifiable(value);
}

PlanHistoryArchive decodePlanHistoryBackup(String source) {
  if (source.length > 8 * 1024 * 1024) {
    throw const FormatException('Plan history exceeds size limit');
  }
  final data = jsonDecode(source);
  if (data is! Map<String, dynamic> ||
      data.length != 4 ||
      data.keys.toSet().difference({
        'format', 'schema_version', 'snapshots', 'blocks',
      }).isNotEmpty ||
      data['format'] != 'life-ai-planner-plan-history' ||
      data['schema_version'] != 1 ||
      data['snapshots'] is! List ||
      data['blocks'] is! List) {
    throw const FormatException('Unsupported plan history archive');
  }
  final rawHeaders = data['snapshots'] as List;
  final rawBlocks = data['blocks'] as List;
  if (rawHeaders.length > 10000 || rawBlocks.length > 100000) {
    throw const FormatException('Plan history archive exceeds row limits');
  }
  final headers = <Map<String, Object?>>[];
  final windows = <int, (int, int)>{};
  var lastId = 0;
  for (final value in rawHeaders) {
    final h = _record(value, _headerKeys);
    final id = h['id'];
    final created = h['created_utc_ms'];
    final start = h['window_start_utc_ms'];
    final end = h['window_end_utc_ms'];
    final budget = h['budget_minutes'];
    final reserve = h['reserved_minutes'];
    if (id is! int || id <= lastId ||
        created is! int || created <= 0 ||
        start is! int || end is! int || start >= end ||
        budget is! int || budget < 0 ||
        reserve is! int || reserve < 0) {
      throw const FormatException('Invalid plan snapshot');
    }
    lastId = id;
    windows[id] = (start, end);
    headers.add(h);
  }
  final blocks = <Map<String, Object?>>[];
  final positions = <int, int>{};
  final ends = <int, int>{};
  final ids = <int, Set<String>>{};
  var previousSnapshotId = 0;
  for (final value in rawBlocks) {
    final b = _record(value, _blockKeys);
    final snapshot = b['snapshot_id'];
    final position = b['position'];
    final taskId = b['task_id'];
    final start = b['start_utc_ms'];
    final end = b['end_utc_ms'];
    if (snapshot is! int || !windows.containsKey(snapshot) ||
        snapshot < previousSnapshotId ||
        position is! int || position != (positions[snapshot] ?? 0) ||
        taskId is! String || taskId.trim().isEmpty ||
        !(ids.putIfAbsent(snapshot, () => <String>{})).add(taskId) ||
        start is! int || end is! int || start >= end ||
        start < windows[snapshot]!.$1 || end > windows[snapshot]!.$2 ||
        (ends[snapshot] != null && start < ends[snapshot]!)) {
      throw const FormatException('Invalid plan history block');
    }
    previousSnapshotId = snapshot;
    positions[snapshot] = position + 1;
    ends[snapshot] = end;
    blocks.add(b);
  }
  return PlanHistoryArchive(List.unmodifiable(headers), List.unmodifiable(blocks));
}

/// Explicit opt-in operation: never overwrites an existing plan history.
/// A failed insert rolls back all inserted rows.
Future<int> restorePlanHistoryIntoEmptyDatabase(
    Database db, PlanHistoryArchive archive) async {
  // Revalidate even if the archive was constructed by untrusted caller code.
  final checked = decodePlanHistoryBackup(jsonEncode({
    'format': 'life-ai-planner-plan-history',
    'schema_version': 1,
    'snapshots': archive.snapshots,
    'blocks': archive.blocks,
  }));
  return db.transaction((txn) async {
    final existing = await txn.query('plan_snapshots', columns: ['id'], limit: 1);
    final existingBlocks = await txn.query(
        'plan_snapshot_blocks', columns: ['snapshot_id'], limit: 1);
    if (existing.isNotEmpty || existingBlocks.isNotEmpty) {
      throw StateError('Plan history must be empty before restoration');
    }
    final batch = txn.batch();
    for (final row in checked.snapshots) {
      batch.insert('plan_snapshots', row);
    }
    for (final row in checked.blocks) {
      batch.insert('plan_snapshot_blocks', row);
    }
    await batch.commit(noResult: true);
    return checked.snapshots.length;
  });
}

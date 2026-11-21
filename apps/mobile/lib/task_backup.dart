import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'plan_snapshot_store.dart';

/// Versioned, offline-only task backup. Plan history is deliberately excluded:
/// restoring tasks must not silently rewrite accepted plan versions.
const taskBackupFormat = 'life-ai-planner-tasks';
const taskBackupVersion = 1;
const _columns = [
  'id', 'title', 'done', 'minutes', 'priority', 'deadline_utc_ms',
];

class TaskBackup {
  const TaskBackup(this.tasks);
  final List<Map<String, Object?>> tasks;
}

Map<String, Object?> _validateTask(Map<String, Object?> row) {
  if (row.keys.toSet().difference(_columns.toSet()).isNotEmpty ||
      row.keys.toSet().difference(_columns.toSet()).length != 0 ||
      !_columns.every(row.containsKey)) {
    throw const FormatException('Unexpected or missing task fields');
  }
  final id = row['id'];
  final title = row['title'];
  final done = row['done'];
  final minutes = row['minutes'];
  final priority = row['priority'];
  final deadline = row['deadline_utc_ms'];
  if (id is! int || id <= 0 ||
      title is! String || title.trim().isEmpty || title.length > 500 ||
      done is! int || (done != 0 && done != 1) ||
      (minutes != null && (minutes is! int || minutes < 1 || minutes > 1440)) ||
      priority is! int || priority < 0 || priority > 10 ||
      (deadline != null && (deadline is! int || deadline <= 0))) {
    throw const FormatException('Invalid task data');
  }
  return {for (final key in _columns) key: row[key]};
}

TaskBackup decodeTaskBackup(String source) {
  if (source.length > 8 * 1024 * 1024) {
    throw const FormatException('Backup exceeds 8 MiB');
  }
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException {
    rethrow;
  }
  if (decoded is! Map<String, dynamic> ||
      decoded.keys.toSet().difference({
        'format', 'schema_version', 'tasks',
      }).isNotEmpty ||
      decoded.length != 3 ||
      decoded['format'] != taskBackupFormat ||
      decoded['schema_version'] != taskBackupVersion ||
      decoded['tasks'] is! List) {
    throw const FormatException('Unsupported backup format');
  }
  final items = decoded['tasks'] as List;
  if (items.length > 10000) {
    throw const FormatException('Too many tasks');
  }
  final seen = <int>{};
  final rows = <Map<String, Object?>>[];
  for (final item in items) {
    if (item is! Map<String, dynamic>) {
      throw const FormatException('Task must be an object');
    }
    final row = _validateTask(item);
    if (!seen.add(row['id'] as int)) {
      throw const FormatException('Duplicate task identifier');
    }
    rows.add(Map.unmodifiable(row));
  }
  rows.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
  return TaskBackup(List.unmodifiable(rows));
}

String encodeTaskBackup(List<Map<String, Object?>> rows) {
  if (rows.length > 10000) {
    throw const FormatException('Too many tasks');
  }
  final validated = <Map<String, Object?>>[];
  final seen = <int>{};
  for (final row in rows) {
    final task = _validateTask(row);
    if (!seen.add(task['id'] as int)) {
      throw const FormatException('Duplicate task identifier');
    }
    validated.add(task);
  }
  validated.sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
  final output = const JsonEncoder.withIndent('  ').convert({
    'format': taskBackupFormat,
    'schema_version': taskBackupVersion,
    'tasks': validated,
  });
  if (output.length > 8 * 1024 * 1024) {
    throw const FormatException('Backup exceeds 8 MiB');
  }
  return output;
}

/// Restore is all-or-nothing. A stale preview cannot overwrite later edits.
/// The caller must explicitly confirm replacement before invoking this.
Future<int> restoreTaskBackup(Database db, TaskBackup backup, {
  required List<Map<String, Object?>> expectedTasks,
}) async {
  // Revalidate even if a caller constructs TaskBackup directly.
  final validated = decodeTaskBackup(encodeTaskBackup(backup.tasks));
  return db.transaction((txn) async {
    final current = await txn.query('tasks');
    if (taskRowsFingerprint(current) != taskRowsFingerprint(expectedTasks)) {
      throw StateError('Tasks changed since restore preview');
    }
    await txn.delete('tasks');
    final batch = txn.batch();
    for (final task in validated.tasks) {
      batch.insert('tasks', task);
    }
    await batch.commit(noResult: true);
    return validated.tasks.length;
  });
}

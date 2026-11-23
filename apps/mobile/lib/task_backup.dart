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
  if (row.length != _columns.length ||
      row.keys.toSet().difference(_columns.toSet()).isNotEmpty ||
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

/// Preview the exact impact before replacing any local task data.
class TaskRestorePreview {
  const TaskRestorePreview({
    required this.currentCount,
    required this.backupCount,
    required this.added,
    required this.removed,
    required this.changed,
    required this.unchanged,
  });
  final int currentCount;
  final int backupCount;
  final int added;
  final int removed;
  final int changed;
  final int unchanged;
}

TaskRestorePreview previewTaskRestore(
    List<Map<String, Object?>> current, TaskBackup backup) {
  final existing = <int, Map<String, Object?>>{};
  for (final raw in current) {
    final row = _validateTask(raw);
    final id = row['id'] as int;
    if (existing.containsKey(id)) {
      throw const FormatException('Duplicate current task identifier');
    }
    existing[id] = row;
  }
  final target = decodeTaskBackup(encodeTaskBackup(backup.tasks)).tasks;
  final targetIds = <int>{};
  var added = 0;
  var changed = 0;
  var unchanged = 0;
  for (final row in target) {
    final id = row['id'] as int;
    targetIds.add(id);
    final old = existing[id];
    if (old == null) {
      added++;
    } else if (taskRowsFingerprint([old]) == taskRowsFingerprint([row])) {
      unchanged++;
    } else {
      changed++;
    }
  }
  return TaskRestorePreview(
    currentCount: existing.length,
    backupCount: target.length,
    added: added,
    removed: existing.keys.where((id) => !targetIds.contains(id)).length,
    changed: changed,
    unchanged: unchanged,
  );
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
    // Apply the smallest possible change set. Deleting and reinserting every
    // task would fire DELETE triggers, break future FK references and rewrite
    // unchanged records even for an identical backup.
    final existing = <int, Map<String, Object?>>{};
    for (final raw in current) {
      final row = _validateTask(raw);
      existing[row['id'] as int] = row;
    }
    final target = <int, Map<String, Object?>>{
      for (final row in validated.tasks) row['id'] as int: row,
    };
    final batch = txn.batch();
    for (final id in existing.keys) {
      if (!target.containsKey(id)) {
        batch.delete('tasks', where: 'id = ?', whereArgs: [id]);
      }
    }
    for (final entry in target.entries) {
      final previous = existing[entry.key];
      if (previous == null) {
        batch.insert('tasks', entry.value);
      } else if (taskRowsFingerprint([previous]) !=
          taskRowsFingerprint([entry.value])) {
        batch.update('tasks', {
          for (final key in _columns)
            if (key != 'id') key: entry.value[key],
        }, where: 'id = ?', whereArgs: [entry.key]);
      }
    }
    await batch.commit(noResult: true);
    return validated.tasks.length;
  });
}

import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'plan_history_backup.dart';
import 'plan_history_restore.dart';
import 'task_backup.dart';

/// Read-only, consistent full offline archive. Import is deliberately not
/// exposed: separate task/history restores cannot guarantee atomicity.
Future<String> exportCombinedBackup(Database db) async {
  return db.transaction((txn) async {
    final tasks = await txn.query('tasks', orderBy: 'id ASC');
    final taskArchive = encodeTaskBackup(tasks);
    // A nested transaction is not supported by sqflite. Read plan tables
    // within the same outer transaction, then validate through the same
    // strict history decoder used by the import path.
    final snapshots = await txn.query('plan_snapshots', orderBy: 'id ASC');
    final blocks = await txn.query('plan_snapshot_blocks',
        orderBy: 'snapshot_id ASC, position ASC');
    final history = jsonEncode({
      'format': 'life-ai-planner-plan-history',
      'schema_version': 1,
      'snapshots': snapshots,
      'blocks': blocks,
    });
    final checked = decodePlanHistoryBackup(history);
    final taskIds = tasks.map((row) => (row['id'] as int).toString()).toSet();
    for (final block in checked.blocks) {
      if (!taskIds.contains(block['task_id'])) {
        throw const FormatException(
            'Plan history refers to a missing task; backup not created');
      }
    }
    final output = const JsonEncoder.withIndent('  ').convert({
      'format': 'life-ai-planner-combined-backup',
      'schema_version': 1,
      'tasks': jsonDecode(taskArchive),
      'plan_history': jsonDecode(history),
    });
    if (output.length > 8 * 1024 * 1024) {
      throw const FormatException('Combined backup exceeds 8 MiB');
    }
    return output;
  });
}

/// Validate a combined archive without modifying local data.
void validateCombinedBackup(String source) {
  if (source.length > 8 * 1024 * 1024) {
    throw const FormatException('Combined backup exceeds 8 MiB');
  }
  final value = jsonDecode(source);
  if (value is! Map<String, dynamic> || value.length != 4 ||
      value.keys.toSet().difference({
        'format', 'schema_version', 'tasks', 'plan_history',
      }).isNotEmpty ||
      value['format'] != 'life-ai-planner-combined-backup' ||
      value['schema_version'] != 1) {
    throw const FormatException('Unsupported combined backup');
  }
  final tasks = decodeTaskBackup(jsonEncode(value['tasks']));
  final history = decodePlanHistoryBackup(jsonEncode(value['plan_history']));
  final ids = tasks.tasks.map((row) => (row['id'] as int).toString()).toSet();
  for (final block in history.blocks) {
    if (!ids.contains(block['task_id'])) {
      throw const FormatException('Plan history references a missing task');
    }
  }
}

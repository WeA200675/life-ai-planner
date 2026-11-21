import 'dart:convert';

import 'plan_snapshot_store.dart';

/// Stable, offline-only export of a saved plan. Never includes the task
/// database, private notes, credentials, or network requests.
String exportSavedPlanJson(SavedPlan plan) {
  if (plan.id <= 0 || plan.createdUtcMs <= 0) {
    throw ArgumentError('Invalid saved plan metadata');
  }
  final blocks = <Map<String, Object>>[];
  final ids = <String>{};
  for (final block in plan.blocks) {
    if (block.id.trim().isEmpty || !ids.add(block.id) ||
        !block.start.isBefore(block.end)) {
      throw ArgumentError('Invalid or duplicate plan block');
    }
    blocks.add({
      'task_id': block.id,
      'start_utc': block.start.toUtc().toIso8601String(),
      'end_utc': block.end.toUtc().toIso8601String(),
    });
  }
  blocks.sort((a, b) =>
      (a['start_utc'] as String).compareTo(b['start_utc'] as String));
  for (var i = 1; i < blocks.length; i++) {
    if ((blocks[i - 1]['end_utc'] as String)
        .compareTo(blocks[i]['start_utc'] as String) > 0) {
      throw ArgumentError('Overlapping plan blocks');
    }
  }
  return const JsonEncoder.withIndent('  ').convert({
    'schema_version': 1,
    'format': 'life-ai-planner-saved-plan',
    'plan_id': plan.id,
    'created_utc': DateTime.fromMillisecondsSinceEpoch(
        plan.createdUtcMs, isUtc: true).toIso8601String(),
    'blocks': blocks,
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/offline_day_planner.dart';
import 'package:life_ai_planner/plan_export.dart';
import 'package:life_ai_planner/plan_snapshot_store.dart';

void main() {
  final start = DateTime.utc(2026, 11, 21, 8);
  final created = DateTime.utc(2026, 11, 21, 7).millisecondsSinceEpoch;

  test('JSON export is deterministic, UTC and contains only explicit fields', () {
    final blocks = [
      DayBlock('second', start.add(const Duration(hours: 1)),
          start.add(const Duration(hours: 2))),
      DayBlock('first', start, start.add(const Duration(minutes: 30))),
    ];
    final plan = SavedPlan(42, blocks, created);
    final json = exportSavedPlanJson(plan);
    expect(json, exportSavedPlanJson(plan));
    final payload = jsonDecode(json) as Map<String, dynamic>;
    expect(payload.keys.toSet(),
        {'schema_version', 'format', 'plan_id', 'created_utc', 'blocks'});
    expect(payload['schema_version'], 1);
    expect(payload['plan_id'], 42);
    final exported = payload['blocks'] as List<dynamic>;
    expect(exported.first['task_id'], 'first');
    expect(exported.last['task_id'], 'second');
    expect(exported.first['start_utc'], startsWith('2026-11-21T08:00:00'));
    expect(exported.first.keys.toSet(),
        {'task_id', 'start_utc', 'end_utc'});
  });

  test('export rejects duplicate, overlapping and invalid blocks', () {
    final a = DayBlock('x', start, start.add(const Duration(hours: 1)));
    final duplicate = DayBlock('x', start.add(const Duration(hours: 1)),
        start.add(const Duration(hours: 2)));
    final overlapping = DayBlock('y', start.add(const Duration(minutes: 30)),
        start.add(const Duration(hours: 2)));
    for (final blocks in [[a, duplicate], [a, overlapping]]) {
      expect(() => exportSavedPlanJson(SavedPlan(1, blocks, created)),
          throwsArgumentError);
    }
    expect(() => exportSavedPlanJson(SavedPlan(0, const [], created)),
        throwsArgumentError);
  });

  test('empty plan export is valid and portable', () {
    final data = jsonDecode(
        exportSavedPlanJson(SavedPlan(1, const [], created))) as Map;
    expect(data['blocks'], isEmpty);
  });
}

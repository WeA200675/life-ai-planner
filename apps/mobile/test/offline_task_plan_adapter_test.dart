import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/offline_task_plan_adapter.dart';

void main() {
  final start = DateTime.utc(2026, 1, 12, 8);
  final end = DateTime.utc(2026, 1, 12, 10);

  test('only open SQLite tasks are planned without changing rows', () {
    final rows = <Map<String, Object?>>[
      {'id': 1, 'title': 'Alpha', 'done': 0},
      {'id': 2, 'title': 'Beta', 'done': 1},
      {'id': 3, 'title': 'Gamma', 'done': 0},
    ];
    final plan = previewLocalTasks(start, end, rows);
    expect(plan.blocks.map((b) => b.id), ['1', '3']);
    expect(plan.budgetMinutes, 84);
    expect(plan.reservedMinutes, 60);
    expect(rows[0]['done'], 0);
    expect(rows[1]['done'], 1);
  });

  test('capacity shortage defers tasks without deleting them', () {
    final rows = List.generate(4, (i) =>
        <String, Object?>{'id': i + 1, 'done': 0});
    final plan = previewLocalTasks(start, end, rows);
    expect(plan.blocks.length, 2);
    expect(plan.deferred, ['3', '4']);
    expect(plan.conflicts.length, 2);
    expect(rows.length, 4);
  });

  test('malformed rows and invalid estimates fail explicitly', () {
    expect(() => previewLocalTasks(start, end,
        [{'id': -1, 'done': 0}]), throwsFormatException);
    expect(() => previewLocalTasks(start, end,
        [{'id': 1, 'done': null}]), throwsFormatException);
    expect(() => previewLocalTasks(start, end, [],
        provisionalMinutes: 0), throwsArgumentError);
  });
}

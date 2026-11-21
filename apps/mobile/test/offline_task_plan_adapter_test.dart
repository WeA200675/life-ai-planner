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
  test('provisional estimates respect SQLite maximum duration', () {
    expect(() => previewLocalTasks(start, end, [
      {'id': 1, 'done': 0},
    ], provisionalMinutes: 1441), throwsArgumentError);
    expect(() => previewLocalTasks(start, end, [
      {'id': 1, 'done': 0},
    ], provisionalMinutes: -1), throwsArgumentError);
    final plan = previewLocalTasks(start, end, [
      {'id': 1, 'done': 0},
    ], provisionalMinutes: 1440);
    expect(plan.deferred, ['1']);
    expect(plan.blocks, isEmpty);
  });

  test('persisted minutes and priority control ordering without mutation', () {
    final rows = <Map<String, Object?>>[
      {'id': 1, 'done': 0, 'minutes': 50, 'priority': 0},
      {'id': 2, 'done': 0, 'minutes': 60, 'priority': 10},
      {'id': 3, 'done': 0, 'minutes': 20, 'priority': 5},
    ];
    final plan = previewLocalTasks(start, end, rows);
    expect(plan.blocks.map((b) => b.id).toList(), ['2', '3']);
    expect(plan.deferred, ['1']);
    expect(rows[1]['minutes'], 60);
  });

  test('legacy rows use provisional duration and zero priority', () {
    final rows = <Map<String, Object?>>[
      {'id': 1, 'done': 0},
      {'id': 2, 'done': 0, 'minutes': 10, 'priority': 10},
    ];
    final plan = previewLocalTasks(start, end, rows);
    expect(plan.blocks.map((b) => b.id).toList(), ['2', '1']);
  });

  test('invalid planning metadata fails instead of silently scheduling', () {
    for (final row in <Map<String, Object?>>[
      {'id': 1, 'done': 0, 'minutes': 0},
      {'id': 1, 'done': 0, 'minutes': 1441},
      {'id': 1, 'done': 0, 'minutes': '30'},
      {'id': 1, 'done': 0, 'priority': -1},
      {'id': 1, 'done': 0, 'priority': 11},
      {'id': 1, 'done': 0, 'priority': true},
    ]) {
      expect(() => previewLocalTasks(start, end, [row]), throwsFormatException);
    }
  });

  test('UTC deadline rejects a task that cannot finish in time', () {
    final rows = <Map<String, Object?>>[
      {'id': 1, 'done': 0, 'minutes': 30,
       'deadline_utc_ms': DateTime.utc(2026, 1, 12, 8, 15).millisecondsSinceEpoch},
    ];
    final plan = previewLocalTasks(start, end, rows);
    expect(plan.blocks, isEmpty);
    expect(plan.deferred, ['1']);
    expect(plan.conflicts.single, contains('no feasible time slot'));
  });

  test('invalid UTC deadline metadata fails explicitly', () {
    for (final invalid in [0, -1, 'tomorrow', true]) {
      expect(() => previewLocalTasks(start, end, [
        {'id': 1, 'done': 0, 'deadline_utc_ms': invalid}
      ]), throwsFormatException);
    }
  });

  test('duplicate open task IDs fail rather than scheduling twice', () {
    expect(() => previewLocalTasks(start, end, [
      {'id': 1, 'done': 0},
      {'id': 1, 'done': 0},
    ]), throwsFormatException);
  });

  test('duplicate IDs are rejected even when one task is completed', () {
    expect(() => previewLocalTasks(start, end, [
      {'id': 1, 'done': 1},
      {'id': 1, 'done': 0},
    ]), throwsFormatException);
  });

  test('remaining-day preview excludes completed tasks and respects current time', () {
    final now = DateTime.utc(2026, 1, 12, 9);
    final rows = <Map<String, Object?>>[
      {'id': 1, 'done': 1, 'minutes': 15},
      {'id': 2, 'done': 0, 'minutes': 20},
    ];
    final plan = replanLocalTasks(now, end, rows);
    expect(plan.capacityMinutes, 60);
    expect(plan.budgetMinutes, 42);
    expect(plan.blocks.map((b) => b.id).toList(), ['2']);
    expect(plan.blocks.single.start, now);
    expect(rows[0]['done'], 1);
  });

  test('remaining-day preview rejects elapsed windows and corrupt rows', () {
    expect(() => replanLocalTasks(end, end, []), throwsArgumentError);
    expect(() => replanLocalTasks(start, end, [
      {'id': 1, 'done': 0, 'minutes': 'invalid'},
    ]), throwsFormatException);
  });


}

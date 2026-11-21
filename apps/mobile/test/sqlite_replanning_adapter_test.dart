import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/offline_task_plan_adapter.dart';
import 'package:life_ai_planner/offline_day_planner.dart';

void main() {
  final now = DateTime.utc(2026, 11, 21, 12);
  final end = DateTime.utc(2026, 11, 21, 14);

  test('SQLite interruption replanning excludes done rows and protects appointments', () {
    final rows = <Map<String, Object?>>[
      {'id': 1, 'done': 1, 'minutes': 20, 'priority': 10},
      {'id': 2, 'done': 0, 'minutes': 30, 'priority': 5},
      {'id': 3, 'done': 0, 'minutes': null, 'priority': null},
    ];
    final meeting = DayBlock('meeting',
        now.subtract(const Duration(minutes: 10)),
        now.add(const Duration(minutes: 30)));
    final plan = replanLocalTasks(now, end, rows, fixed: [meeting]);
    expect(plan.blocks.map((block) => block.id), ['meeting', '2', '3']);
    expect(plan.blocks.first.start, now);
    expect(plan.blocks.first.end, meeting.end);
    expect(plan.budgetMinutes, 62);
    expect(plan.reservedMinutes, 30);
    expect(rows[1]['minutes'], 30);
    expect(rows[2]['minutes'], isNull);
  });

  test('malformed SQLite rows fail closed without mutating inputs', () {
    for (final row in <Map<String, Object?>>[
      {'id': 1, 'done': 0, 'minutes': 1441},
      {'id': 1, 'done': 0, 'priority': true},
      {'id': 1, 'done': 2},
      {'id': '1', 'done': 0},
    ]) {
      expect(() => replanLocalTasks(now, end, [row]), throwsFormatException);
    }
    final duplicate = <Map<String, Object?>>[
      {'id': 1, 'done': 1}, {'id': 1, 'done': 0},
    ];
    expect(() => replanLocalTasks(now, end, duplicate), throwsFormatException);
    expect(() => replanLocalTasks(now, end, [], provisionalMinutes: 0),
        throwsArgumentError);
    expect(() => replanLocalTasks(end, now, []), throwsArgumentError);
  });
}

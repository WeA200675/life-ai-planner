import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/deferred_task_explanation.dart';
import 'package:life_ai_planner/offline_day_planner.dart';

void main() {
  final start = DateTime.utc(2026, 11, 23, 8);
  final end = DateTime.utc(2026, 11, 23, 10);

  test('capacity deferral is explained without mutating the task', () {
    final task = DayTask(id: 'synthetic', minutes: 90);
    final plan = planOfflineDay(start, end, [task]);
    expect(plan.deferred, ['synthetic']);
    expect(deferredTaskExplanation(plan, task.id), contains('Planbudget'));
    expect(task.minutes, 90);
  });

  test('deadline conflict explains missing feasible time window', () {
    final task = DayTask(id: 'deadline', minutes: 30,
        deadline: DateTime.utc(2026, 11, 23, 8, 15));
    final plan = planOfflineDay(start, end, [task]);
    expect(deferredTaskExplanation(plan, task.id), contains('Fälligkeit'));
  });

  test('nondeferred task cannot be presented as a conflict', () {
    final plan = planOfflineDay(start, end, [const DayTask(id: 'ok', minutes: 10)]);
    expect(() => deferredTaskExplanation(plan, 'ok'), throwsArgumentError);
  });

  test('unknown scheduler reason falls back without exposing internals', () {
    final plan = DayPlan(const [], const ['a'], const ['a: future reason'], 120, 84, 120);
    expect(deferredTaskExplanation(plan, 'a'), contains('Planungskonflikt'));
  });
}

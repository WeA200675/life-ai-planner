import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/offline_day_planner.dart';

void main() {
  final start = DateTime.utc(2026, 1, 12, 8);
  final end = DateTime.utc(2026, 1, 12, 10);
  test('70/30 budget and deterministic priority order', () {
    final tasks = [
      const DayTask(id: 'low', minutes: 50, priority: 0),
      const DayTask(id: 'high', minutes: 60, priority: 10),
      const DayTask(id: 'short', minutes: 20, priority: 5),
    ];
    final plan = planOfflineDay(start, end, tasks);
    expect(plan.capacityMinutes, 120);
    expect(plan.budgetMinutes, 84);
    expect(plan.blocks.map((b) => b.id).toList(), ['high', 'short']);
    expect(plan.deferred, ['low']);
    expect(plan.reservedMinutes, 40);
  });
  test('protected appointment is preserved and gaps respected', () {
    final fixed = DayBlock('meeting', start.add(const Duration(minutes: 30)),
        start.add(const Duration(minutes: 60)));
    final plan = planOfflineDay(start, end,
        [const DayTask(id: 'task', minutes: 45)], fixed: [fixed]);
    expect(plan.blocks.where((b) => b.id == 'meeting').single.start, fixed.start);
    expect(plan.blocks.where((b) => b.id == 'task').single.start, fixed.end);
    expect(plan.budgetMinutes, 62);
  });
  test('fixed appointment identifiers cannot collide with tasks or each other', () {
    final meeting = DayBlock('meeting', start, start.add(const Duration(minutes: 15)));
    expect(() => planOfflineDay(start, end,
        [const DayTask(id: 'meeting', minutes: 10)], fixed: [meeting]),
        throwsArgumentError);
    expect(() => planOfflineDay(start, end, [], fixed: [meeting, meeting]),
        throwsArgumentError);
    expect(() => planOfflineDay(start, end, [], fixed: [
      DayBlock('  ', start, start.add(const Duration(minutes: 15))),
    ]), throwsArgumentError);
  });
  test('deadline conflicts are explicit without dropping tasks', () {
    final plan = planOfflineDay(start, end, [
      DayTask(id: 'early', minutes: 40,
          deadline: start.add(const Duration(minutes: 20))),
    ]);
    expect(plan.blocks, isEmpty);
    expect(plan.deferred, ['early']);
    expect(plan.conflicts.single, contains('no feasible time slot'));
  });
  test('invalid windows, overlaps and duplicate ids are rejected', () {
    expect(() => planOfflineDay(end, start, []), throwsArgumentError);
    expect(() => planOfflineDay(start, end, [], bufferRatio: double.nan),
        throwsArgumentError);
    expect(() => planOfflineDay(start, end, [
      const DayTask(id: 'x', minutes: 1),
      const DayTask(id: 'x', minutes: 2),
    ]), throwsArgumentError);
    expect(() => planOfflineDay(start, end, [], fixed: [
      DayBlock('a', start, start.add(const Duration(minutes: 50))),
      DayBlock('b', start.add(const Duration(minutes: 30)), end),
    ]), throwsArgumentError);
  });
}

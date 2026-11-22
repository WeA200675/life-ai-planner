import 'package:flutter_test/flutter_test.dart';
import '../lib/offline_day_planner.dart';

void main() {
  final start = DateTime.utc(2026, 11, 22, 8);
  final end = DateTime.utc(2026, 11, 22, 18);

  test('70/30 capacity and deterministic priority order', () {
    final tasks = [
      const DayTask(id: 'low', minutes: 60, priority: 1),
      const DayTask(id: 'high', minutes: 60, priority: 10),
    ];
    final result = planOfflineDay(start, end, tasks);
    expect(result.capacityMinutes, 600);
    expect(result.budgetMinutes, 420);
    expect(result.blocks.map((b) => b.id).toList(), ['high', 'low']);
    expect(result.reservedMinutes, 480);
  });

  test('fixed appointments stay immutable and tasks use gaps', () {
    final fixed = [DayBlock('meeting', DateTime.utc(2026, 11, 22, 9),
        DateTime.utc(2026, 11, 22, 10))];
    final result = planOfflineDay(start, end,
        [const DayTask(id: 'work', minutes: 90)], fixed: fixed);
    expect(result.blocks.first.id, 'meeting');
    expect(result.blocks.last.start, DateTime.utc(2026, 11, 22, 10));
    expect(result.budgetMinutes, 378);
  });

  test('oversized task is deferred without consuming budget', () {
    final result = planOfflineDay(start, end,
        [const DayTask(id: 'too-long', minutes: 500)]);
    expect(result.blocks, isEmpty);
    expect(result.deferred, ['too-long']);
    expect(result.conflicts.single, contains('buffer'));
    expect(result.reservedMinutes, 600);
  });

  test('deadline conflict defers task and preserves appointment', () {
    final result = planOfflineDay(start, end, [
      DayTask(id: 'urgent', minutes: 90, priority: 10,
          deadline: DateTime.utc(2026, 11, 22, 9)),
    ]);
    expect(result.blocks, isEmpty);
    expect(result.deferred, ['urgent']);
    expect(result.conflicts.single, contains('no feasible'));
  });

  test('replanning excludes completed work and clips ongoing meeting', () {
    final now = DateTime.utc(2026, 11, 22, 11, 30);
    final result = replanOfflineDay(now, end, [
      const DayTask(id: 'done', minutes: 20),
      const DayTask(id: 'todo', minutes: 30),
    ], completedTaskIds: {'done'}, fixed: [
      DayBlock('meeting', DateTime.utc(2026, 11, 22, 11),
          DateTime.utc(2026, 11, 22, 12)),
    ]);
    expect(result.blocks.map((b) => b.id), ['meeting', 'todo']);
    expect(result.blocks.first.start, now);
    expect(result.blocks.last.start, DateTime.utc(2026, 11, 22, 12));
  });

  test('overlapping fixed blocks fail closed', () {
    expect(() => planOfflineDay(start, end, const [], fixed: [
      DayBlock('a', DateTime.utc(2026, 11, 22, 9),
          DateTime.utc(2026, 11, 22, 10)),
      DayBlock('b', DateTime.utc(2026, 11, 22, 9, 30),
          DateTime.utc(2026, 11, 22, 11)),
    ]), throwsArgumentError);
  });

  test('invalid and duplicate task IDs fail closed', () {
    expect(() => planOfflineDay(start, end, [
      const DayTask(id: 'duplicate', minutes: 30),
      const DayTask(id: 'duplicate', minutes: 20),
    ]), throwsArgumentError);
    expect(() => planOfflineDay(start, end,
        [const DayTask(id: ' ', minutes: 20)]), throwsArgumentError);
  });

  test('replanning rejects unknown completed IDs', () {
    expect(() => replanOfflineDay(start, end,
        [const DayTask(id: 'task', minutes: 30)],
        completedTaskIds: {'unknown'}), throwsArgumentError);
  });

  test('planner leaves caller inputs unchanged', () {
    final tasks = [
      const DayTask(id: 'b', minutes: 30, priority: 1),
      const DayTask(id: 'a', minutes: 30, priority: 10),
    ];
    final original = tasks.map((t) => t.id).toList();
    planOfflineDay(start, end, tasks);
    expect(tasks.map((t) => t.id).toList(), original);
  });
}

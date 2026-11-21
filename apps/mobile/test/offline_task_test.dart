import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/main.dart';

void main() {
  test('invalid task titles are rejected before opening SQLite', () async {
    final store = LocalTasks();
    await expectLater(store.add('  '), throwsArgumentError);
    await expectLater(store.add('x' * 501), throwsArgumentError);
  });

  test('invalid renames are rejected before opening SQLite', () async {
    final store = LocalTasks();
    await expectLater(store.rename(0, 'Valid'), throwsArgumentError);
    await expectLater(store.rename(-1, 'Valid'), throwsArgumentError);
    await expectLater(store.rename(1, '  '), throwsArgumentError);
    await expectLater(store.rename(1, 'x' * 501), throwsArgumentError);
  });

  test('invalid completion ids are rejected before opening SQLite', () async {
    final store = LocalTasks();
    await expectLater(store.setDone(0, true), throwsArgumentError);
    await expectLater(store.setDone(-5, false), throwsArgumentError);
  });

  test('invalid deletion ids are rejected before opening SQLite', () async {
    final store = LocalTasks();
    await expectLater(store.delete(0), throwsArgumentError);
    await expectLater(store.delete(-1), throwsArgumentError);
  });

  test('offline status filters preserve ordering and do not mutate input', () {
    final tasks = <Map<String, Object?>>[
      {'id': 3, 'title': 'Open A', 'done': 0},
      {'id': 2, 'title': 'Completed', 'done': 1},
      {'id': 1, 'title': 'Open B', 'done': 0},
    ];
    expect(visibleTasks(tasks, TaskView.open).map((t) => t['id']), [3, 1]);
    expect(visibleTasks(tasks, TaskView.completed).map((t) => t['id']), [2]);
    expect(visibleTasks(tasks, TaskView.all).length, 3);
    expect(tasks.length, 3);
  });

  test('offline search combines with status filter and preserves source', () {
    final tasks = <Map<String, Object?>>[
      {'id': 1, 'title': 'Buy Bread', 'done': 0},
      {'id': 2, 'title': 'BUY MILK', 'done': 1},
      {'id': 3, 'title': 'Call', 'done': 0},
    ];
    expect(visibleTasks(tasks, TaskView.open, ' buy ').map((t) => t['id']), [1]);
    expect(visibleTasks(tasks, TaskView.completed, 'BUY').map((t) => t['id']), [2]);
    expect(visibleTasks(tasks, TaskView.all, 'missing'), isEmpty);
    expect(visibleTasks(tasks, TaskView.all, '  ').length, 3);
    expect(tasks.length, 3);
  });

  testWidgets('offline task filters remain available without database',
      (tester) async {
    await tester.pumpWidget(const PlannerApp());
    expect(find.text('Offen'), findsOneWidget);
    expect(find.text('Erledigt'), findsOneWidget);
    expect(find.text('Alle'), findsOneWidget);
  });

  testWidgets('offline text fallback is always visible', (tester) async {
    await tester.pumpWidget(const PlannerApp());
    expect(find.text('Life AI Planner – Offline'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Aufgaben suchen'), findsOneWidget);
    expect(find.byTooltip('Aufgabe speichern'), findsOneWidget);
  });
}

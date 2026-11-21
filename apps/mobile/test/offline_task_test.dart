import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/main.dart';

void main() {
  test('invalid task titles are rejected before opening SQLite', () async {
    final store = LocalTasks();
    await expectLater(store.add('  '), throwsArgumentError);
    await expectLater(store.add('x' * 501), throwsArgumentError);
  });

  testWidgets('offline text fallback is always visible', (tester) async {
    await tester.pumpWidget(const PlannerApp());
    expect(find.text('Life AI Planner – Offline'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byTooltip('Aufgabe speichern'), findsOneWidget);
  });
}

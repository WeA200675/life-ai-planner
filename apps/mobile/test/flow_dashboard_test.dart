import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/flow_dashboard.dart';

void main() {
  testWidgets('organic dashboard renders counters and delegates planning actions',
      (tester) async {
    var previews = 0;
    var replans = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(
      child: FlowDashboard(
        open: 4, completed: 2, enabled: true,
        onPreview: () => previews++,
        onReplan: () => replans++,
        onSaved: () {}, onHistory: () {}, onBackup: () {}, onRestore: () {},
      ),
    ))));
    expect(find.text('MIDNIGHT FLOW'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    await tester.tap(find.text('Planen'));
    expect(previews, 1);
    await tester.tap(find.text('Neu planen'));
    expect(replans, 1);
  });

  testWidgets('disabled dashboard does not invoke planning actions',
      (tester) async {
    var calls = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(
      child: FlowDashboard(
        open: 0, completed: 0, enabled: false,
        onPreview: () => calls++,
        onReplan: () => calls++,
        onSaved: () => calls++, onHistory: () => calls++,
        onBackup: () => calls++, onRestore: () => calls++,
      ),
    ))));
    await tester.tap(find.text('Planen'));
    expect(calls, 0);
  });
}

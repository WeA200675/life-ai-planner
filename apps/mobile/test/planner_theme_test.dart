import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/planner_theme.dart';

void main() {
  test('midnight theme is dark, red-led and uses accessible contrast', () {
    final theme = PlannerTheme.dark;
    expect(theme.brightness, Brightness.dark);
    expect(theme.scaffoldBackgroundColor, PlannerTheme.background);
    expect(theme.colorScheme.primary, PlannerTheme.coral);
    expect(theme.colorScheme.onPrimary, PlannerTheme.background);
    expect(theme.colorScheme.secondary, PlannerTheme.turquoise);
    expect(theme.dialogTheme.backgroundColor, PlannerTheme.surface);
    expect(ThemeData.estimateBrightnessForColor(theme.colorScheme.primary),
        Brightness.dark);
  });

  testWidgets('theme is usable without animation or network', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: PlannerTheme.dark,
      home: const Scaffold(body: Center(child: Text('Offline'))),
    ));
    expect(find.text('Offline'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

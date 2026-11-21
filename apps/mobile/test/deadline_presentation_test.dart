import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/deadline_presentation.dart';

void main() {
  int endOfLocalDay(int year, int month, int day) =>
      DateTime(year, month, day + 1)
          .subtract(const Duration(milliseconds: 1))
          .toUtc()
          .millisecondsSinceEpoch;

  test('no deadline and invalid values are explicit', () {
    expect(deadlineLabel(null, DateTime(2026, 1, 1)), 'Keine Fälligkeit');
    expect(() => deadlineLabel(0, DateTime(2026, 1, 1)),
        throwsFormatException);
  });

  test('today, tomorrow and later deadlines are distinct', () {
    final now = DateTime(2026, 6, 10, 12);
    expect(deadlineLabel(endOfLocalDay(2026, 6, 10), now),
        contains('Heute fällig'));
    expect(deadlineLabel(endOfLocalDay(2026, 6, 11), now),
        contains('Morgen fällig'));
    expect(deadlineLabel(endOfLocalDay(2026, 6, 15), now),
        'Fällig · 15.06.2026');
  });

  test('expired deadline is labelled overdue', () {
    expect(deadlineLabel(endOfLocalDay(2026, 6, 9), DateTime(2026, 6, 10)),
        contains('Überfällig'));
  });

  test('calendar-day classification survives DST transitions', () {
    for (final day in [28, 29]) {
      final now = DateTime(2026, 3, day, 12);
      final nextDay = DateTime(2026, 3, day + 1);
      expect(deadlineLabel(
          endOfLocalDay(nextDay.year, nextDay.month, nextDay.day), now),
          contains('Morgen fällig'));
    }
  });
}

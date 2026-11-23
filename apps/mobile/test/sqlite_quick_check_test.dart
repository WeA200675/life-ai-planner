import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/sqlite_integrity.dart';

void main() {
  group('SQLite structural preflight', () {
    test('accepts only the single ok result', () {
      expect(isSqliteQuickCheckHealthy([{'quick_check': 'ok'}]), isTrue);
    });

    test('rejects empty results', () {
      expect(isSqliteQuickCheckHealthy([]), isFalse);
    });

    test('rejects corruption without exposing its content', () {
      expect(isSqliteQuickCheckHealthy([{'quick_check': 'malformed database'}]), isFalse);
    });

    test('rejects mixed and malformed results', () {
      expect(isSqliteQuickCheckHealthy([
        {'quick_check': 'ok'},
        {'quick_check': 'other'},
      ]), isFalse);
      expect(isSqliteQuickCheckHealthy([{'quick_check': 'ok', 'extra': 1}]), isFalse);
      expect(isSqliteQuickCheckHealthy([{'quick_check': 1}]), isFalse);
    });
  });
}

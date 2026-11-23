import 'package:sqflite/sqflite.dart';

/// A healthy SQLite quick_check returns exactly one row containing "ok".
/// Never log the returned error strings: they may reveal schema details.
bool isSqliteQuickCheckHealthy(List<Map<String, Object?>> rows) {
  if (rows.length != 1) return false;
  final values = rows.single.values;
  return values.length == 1 && values.single == 'ok';
}

/// Check structural consistency before any additive schema mutation.
/// This check is read-only and fails closed without deleting user data.
Future<void> requireValidSqliteStructure(DatabaseExecutor database) async {
  final rows = await database.rawQuery('PRAGMA quick_check');
  if (!isSqliteQuickCheckHealthy(rows)) {
    throw StateError(
      'Local SQLite structural integrity check failed; '
      'database left unchanged. Restore from a verified backup.',
    );
  }
}

/// Detect pre-existing orphan rows without modifying the user's database.
/// Foreign-key enforcement only prevents new violations; it does not repair
/// legacy corruption. Keep diagnostics free of private row contents.
Future<void> requireValidForeignKeys(DatabaseExecutor database) async {
  final violations = await database.rawQuery('PRAGMA foreign_key_check');
  if (violations.isNotEmpty) {
    throw StateError(
      'Local SQLite foreign-key integrity check failed; '
      'database left unchanged. Restore from a verified backup.',
    );
  }
}

import 'package:sqflite/sqflite.dart';

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

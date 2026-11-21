import 'package:sqflite/sqflite.dart';

/// Schema v3 preserves existing task IDs, titles and completion flags.
/// Null metadata means an explicitly provisional 30-minute estimate.
Future<void> createTaskSchema(DatabaseExecutor db) async {
  await db.execute(
    'CREATE TABLE tasks ('
    'id INTEGER PRIMARY KEY AUTOINCREMENT, '
    'title TEXT NOT NULL CHECK(length(trim(title)) > 0), '
    'done INTEGER NOT NULL DEFAULT 0 CHECK(done IN (0, 1)), '
    'minutes INTEGER CHECK(minutes IS NULL OR (minutes BETWEEN 1 AND 1440)), '
    'priority INTEGER NOT NULL DEFAULT 0 CHECK(priority BETWEEN 0 AND 10), '
    'deadline_utc_ms INTEGER CHECK(deadline_utc_ms IS NULL OR deadline_utc_ms > 0))',
  );
}

Future<void> migrateTasksV1ToV2(DatabaseExecutor db) async {
  await db.execute(
    'ALTER TABLE tasks ADD COLUMN minutes INTEGER '
    'CHECK(minutes IS NULL OR (minutes BETWEEN 1 AND 1440))',
  );
  await db.execute(
    'ALTER TABLE tasks ADD COLUMN priority INTEGER NOT NULL DEFAULT 0 '
    'CHECK(priority BETWEEN 0 AND 10)',
  );
}

/// Add optional UTC deadline without rewriting or dropping existing tasks.
Future<void> migrateTasksV2ToV3(DatabaseExecutor db) async {
  await db.execute('ALTER TABLE tasks ADD COLUMN deadline_utc_ms INTEGER '
      'CHECK(deadline_utc_ms IS NULL OR deadline_utc_ms > 0)');
}

import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/local_task_schema.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;

  test('new v2 database enforces metadata bounds and keeps null fallback', () async {
    final db = await factory.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 2, onCreate: (db, _) => createTaskSchema(db)));
    try {
      await db.insert('tasks', {'title': 'Synthetic'});
      final rows = await db.query('tasks');
      expect(rows.single['minutes'], isNull);
      expect(rows.single['priority'], 0);
      await db.update('tasks', {'minutes': 45, 'priority': 8});
      expect((await db.query('tasks')).single['minutes'], 45);
      for (final invalid in [
        {'minutes': 0}, {'minutes': 1441},
        {'priority': -1}, {'priority': 11},
      ]) {
        await expectLater(db.update('tasks', invalid), throwsA(isA<DatabaseException>()));
      }
      expect((await db.query('tasks')).single['minutes'], 45);
    } finally {
      await db.close();
    }
  });

  test('v1 to v2 upgrade preserves IDs, titles and done flags', () async {
    // A temporary file allows closing/reopening with a different schema version.
    final path = '${Directory.systemTemp.createTempSync('planner-schema-').path}/tasks.db';
    try {
      var db = await factory.openDatabase(path, options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'title TEXT NOT NULL, done INTEGER NOT NULL DEFAULT 0)');
        },
      ));
      await db.insert('tasks', {'id': 7, 'title': 'Legacy sample', 'done': 1});
      await db.close();
      db = await factory.openDatabase(path, options: OpenDatabaseOptions(
        version: 2,
        onUpgrade: (db, oldVersion, _) async {
          if (oldVersion < 2) await migrateTasksV1ToV2(db);
        },
      ));
      try {
        final row = (await db.query('tasks')).single;
        expect(row['id'], 7);
        expect(row['title'], 'Legacy sample');
        expect(row['done'], 1);
        expect(row['minutes'], isNull);
        expect(row['priority'], 0);
      } finally {
        await db.close();
      }
    } finally {
      final dir = Directory(path).parent;
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    }
  });
  test('v2 to v3 migration preserves rows and validates UTC deadline', () async {
    final dir = Directory.systemTemp.createTempSync('planner-deadline-');
    final path = '${dir.path}/tasks.db';
    try {
      var db = await factory.openDatabase(path, options: OpenDatabaseOptions(
        version: 2, onCreate: (db, _) => createTaskSchemaV2ForTest(db),
      ));
      await db.insert('tasks', {'id': 17, 'title': 'Sample', 'minutes': 45, 'priority': 8});
      await db.close();
      db = await factory.openDatabase(path, options: OpenDatabaseOptions(
        version: 3, onUpgrade: (db, old, _) async {
          if (old < 3) await migrateTasksV2ToV3(db);
        },
      ));
      try {
        final row = (await db.query('tasks')).single;
        expect(row['id'], 17);
        expect(row['minutes'], 45);
        expect(row['priority'], 8);
        expect(row['deadline_utc_ms'], isNull);
        await db.update('tasks', {'deadline_utc_ms': 1768212000000});
        expect((await db.query('tasks')).single['deadline_utc_ms'], 1768212000000);
        await expectLater(db.update('tasks', {'deadline_utc_ms': 0}),
            throwsA(isA<DatabaseException>()));
      } finally {
        await db.close();
      }
    } finally {
      dir.deleteSync(recursive: true);
    }
  });

  test('fresh v3 schema includes nullable deadline', () async {
    final db = await factory.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 3, onCreate: (db, _) => createTaskSchema(db)));
    try {
      await db.insert('tasks', {'title': 'Fresh'});
      expect((await db.query('tasks')).single['deadline_utc_ms'], isNull);
      await expectLater(db.update('tasks', {'deadline_utc_ms': -1}),
          throwsA(isA<DatabaseException>()));
    } finally {
      await db.close();
    }
  });

}

Future<void> createTaskSchemaV2ForTest(DatabaseExecutor db) async {
  await db.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'title TEXT NOT NULL, done INTEGER NOT NULL DEFAULT 0, '
      'minutes INTEGER, priority INTEGER NOT NULL DEFAULT 0)');
}

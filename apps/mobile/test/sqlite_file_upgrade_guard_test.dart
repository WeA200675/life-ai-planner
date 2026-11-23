import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/local_task_schema.dart';
import 'package:life_ai_planner/sqlite_integrity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// File-backed migrations, unlike in-memory checks, exercise sqflite's actual
/// onUpgrade callback and verify the persisted database after reopen.
void main() {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;

  late Directory temporary;
  late String path;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('planner-upgrade-test-');
    path = '${temporary.path}/planner.sqlite';
  });

  tearDown(() async {
    await factory.deleteDatabase(path);
    if (await temporary.exists()) await temporary.delete(recursive: true);
  });

  Future<void> upgradeToV2() async {
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        singleInstance: false,
        onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
        onUpgrade: (db, oldVersion, newVersion) async {
          await requireValidSqliteStructure(db);
          await requireValidForeignKeys(db);
          if (oldVersion < 2) await migrateTasksV1ToV2(db);
        },
      ),
    );
    await db.close();
  }

  test('valid legacy file migrates without losing existing tasks', () async {
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        singleInstance: false,
        onCreate: (db, _) async {
          await db.execute('CREATE TABLE tasks ('
              'id INTEGER PRIMARY KEY, title TEXT NOT NULL, done INTEGER NOT NULL)');
          await db.insert('tasks', {'id': 7, 'title': 'Synthetic task', 'done': 1});
        },
      ),
    );
    await db.close();

    await upgradeToV2();

    final reopened = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(singleInstance: false, readOnly: true),
    );
    try {
      final rows = await reopened.query('tasks');
      expect(rows, hasLength(1));
      expect(rows.single['id'], 7);
      expect(rows.single['title'], 'Synthetic task');
      expect(rows.single['done'], 1);
      expect(rows.single['minutes'], isNull);
      expect(rows.single['priority'], 0);
      expect((await reopened.rawQuery('PRAGMA user_version')).single.values.single, 2);
      await requireValidSqliteStructure(reopened);
      await requireValidForeignKeys(reopened);
    } finally {
      await reopened.close();
    }
  });

  test('interrupted migration transaction rolls back schema and rows on disk', () async {
    final initial = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        singleInstance: false,
        onCreate: (db, _) async {
          await db.execute('CREATE TABLE tasks ('
              'id INTEGER PRIMARY KEY, title TEXT NOT NULL, done INTEGER NOT NULL)');
          await db.insert('tasks', {'id': 17, 'title': 'Synthetic original', 'done': 0});
        },
      ),
    );
    await initial.close();

    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    try {
      await expectLater(
        db.transaction((txn) async {
          await requireValidSqliteStructure(txn);
          await requireValidForeignKeys(txn);
          await migrateTasksV1ToV2(txn);
          await txn.update('tasks', {'title': 'Synthetic interrupted'}, where: 'id = ?', whereArgs: [17]);
          // Simulate an interruption after DDL and DML but before commit.
          throw StateError('synthetic interruption');
        }),
        throwsStateError,
      );
    } finally {
      await db.close();
    }

    // Reopen from disk: no partial schema or data mutation may survive.
    final reopened = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(singleInstance: false, readOnly: true),
    );
    try {
      expect((await reopened.rawQuery('PRAGMA user_version')).single.values.single, 1);
      final columns = await reopened.rawQuery('PRAGMA table_info(tasks)');
      expect(columns.map((row) => row['name']), isNot(contains('minutes')));
      expect(columns.map((row) => row['name']), isNot(contains('priority')));
      final rows = await reopened.query('tasks');
      expect(rows, hasLength(1));
      expect(rows.single['id'], 17);
      expect(rows.single['title'], 'Synthetic original');
      await requireValidSqliteStructure(reopened);
      await requireValidForeignKeys(reopened);
    } finally {
      await reopened.close();
    }
  });

  test('orphaned foreign key rejects actual upgrade before any DDL', () async {
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        singleInstance: false,
        onCreate: (db, _) async {
          await db.execute('CREATE TABLE tasks ('
              'id INTEGER PRIMARY KEY, title TEXT NOT NULL, done INTEGER NOT NULL)');
          await db.execute('CREATE TABLE parents (id INTEGER PRIMARY KEY)');
          await db.execute('CREATE TABLE children ('
              'parent_id INTEGER REFERENCES parents(id))');
          // FK enforcement is off on this legacy connection.
          await db.execute('INSERT INTO children(parent_id) VALUES (999)');
          await db.insert('tasks', {'id': 8, 'title': 'Synthetic task', 'done': 0});
        },
      ),
    );
    await db.close();

    await expectLater(upgradeToV2(), throwsStateError);

    // A failed migration must not bump the version or add any columns.
    final reopened = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(singleInstance: false, readOnly: true),
    );
    try {
      expect((await reopened.rawQuery('PRAGMA user_version')).single.values.single, 1);
      final columns = await reopened.rawQuery('PRAGMA table_info(tasks)');
      expect(columns.map((row) => row['name']), isNot(contains('minutes')));
      expect(columns.map((row) => row['name']), isNot(contains('priority')));
      final rows = await reopened.query('tasks');
      expect(rows.single['id'], 8);
      expect(rows.single['title'], 'Synthetic task');
      expect(await reopened.rawQuery('PRAGMA foreign_key_check'), isNotEmpty);
    } finally {
      await reopened.close();
    }
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/sqlite_integrity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// File-based restore acceptance checks using only synthetic tasks.
/// These tests verify cold-backup behavior; they do not claim that an
/// application-level backup/restore UI exists.
void main() {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;
  late Directory directory;
  late String livePath;
  late String backupPath;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('planner-restore-');
    livePath = '${directory.path}/live.sqlite';
    backupPath = '${directory.path}/backup.sqlite';
  });

  tearDown(() async {
    await factory.deleteDatabase(livePath);
    await factory.deleteDatabase(backupPath);
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  Future<void> createSyntheticDatabase() async {
    final db = await factory.openDatabase(
      livePath,
      options: OpenDatabaseOptions(
        version: 1,
        singleInstance: false,
        onCreate: (db, _) async {
          await db.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT NOT NULL)');
          await db.insert('tasks', {'id': 1, 'title': 'Synthetic original'});
        },
      ),
    );
    await db.close();
  }

  Future<void> validateFile(String path) async {
    final db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    try {
      await requireValidSqliteStructure(db);
      await requireValidForeignKeys(db);
    } finally {
      await db.close();
    }
  }

  test('cold backup restores original rows and schema after later edits', () async {
    await createSyntheticDatabase();
    // Never copy an open WAL-mode database: close all connections first.
    await File(livePath).copy(backupPath);
    await validateFile(backupPath);

    final edited = await factory.openDatabase(
      livePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    await edited.update('tasks', {'title': 'Synthetic changed'}, where: 'id = ?', whereArgs: [1]);
    await edited.execute('CREATE TABLE later_changes (id INTEGER)');
    await edited.close();

    // Restore only after closing the live DB; never overwrite an open DB.
    await factory.deleteDatabase(livePath);
    await File(backupPath).copy(livePath);
    final restored = await factory.openDatabase(
      livePath,
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    try {
      expect((await restored.query('tasks')).single['title'], 'Synthetic original');
      expect((await restored.rawQuery('PRAGMA user_version')).single.values.single, 1);
      final tables = await restored.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='later_changes'",
      );
      expect(tables, isEmpty);
      await requireValidSqliteStructure(restored);
      await requireValidForeignKeys(restored);
    } finally {
      await restored.close();
    }
  });

  test('corrupted backup fails validation before live database is touched', () async {
    await createSyntheticDatabase();
    await File(backupPath).writeAsBytes(List<int>.filled(256, 0x58), flush: true);
    await expectLater(validateFile(backupPath), throwsA(isA<Exception>()));
    final live = await factory.openDatabase(
      livePath,
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    try {
      expect((await live.query('tasks')).single['title'], 'Synthetic original');
      await requireValidSqliteStructure(live);
    } finally {
      await live.close();
    }
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/local_task_schema.dart';
import 'package:life_ai_planner/offline_task_plan_adapter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test('deadline survives SQLite close/reopen and reaches offline planner', () async {
    final directory = Directory.systemTemp.createTempSync('planner-deadline-roundtrip-');
    final path = '${directory.path}/tasks.db';
    final deadline = DateTime.utc(2026, 11, 23, 10);
    try {
      var db = await databaseFactoryFfi.openDatabase(path,
          options: OpenDatabaseOptions(
              version: 3, onCreate: (db, _) => createTaskSchema(db)));
      final id = await db.insert('tasks', {
        'title': 'Synthetic deadline task',
        'done': 0,
        'minutes': 60,
        'priority': 5,
      });
      expect(await db.update('tasks',
          {'deadline_utc_ms': deadline.millisecondsSinceEpoch},
          where: 'id = ?', whereArgs: [id]), 1);
      await db.close();

      db = await databaseFactoryFfi.openDatabase(path,
          options: OpenDatabaseOptions(version: 3));
      try {
        final rows = await db.query('tasks');
        expect(rows.single['deadline_utc_ms'], deadline.millisecondsSinceEpoch);
        final plan = previewLocalTasks(
            DateTime.utc(2026, 11, 23, 8),
            DateTime.utc(2026, 11, 23, 18),
            rows);
        expect(plan.blocks.map((block) => block.id), contains(id.toString()));

        expect(await db.update('tasks', {'deadline_utc_ms': null},
            where: 'id = ?', whereArgs: [id]), 1);
        expect((await db.query('tasks')).single['deadline_utc_ms'], isNull);
      } finally {
        await db.close();
      }
    } finally {
      if (directory.existsSync()) directory.deleteSync(recursive: true);
    }
  });

  test('expired persisted deadline is deferred rather than scheduled', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(
            version: 3, onCreate: (db, _) => createTaskSchema(db)));
    try {
      final id = await db.insert('tasks', {
        'title': 'Synthetic expired task',
        'done': 0,
        'minutes': 30,
        'deadline_utc_ms': DateTime.utc(2026, 11, 22).millisecondsSinceEpoch,
      });
      final plan = previewLocalTasks(
          DateTime.utc(2026, 11, 23, 8),
          DateTime.utc(2026, 11, 23, 18),
          await db.query('tasks'));
      expect(plan.deferred, contains(id.toString()));
      expect(plan.blocks.where((block) => block.id == id.toString()), isEmpty);
    } finally {
      await db.close();
    }
  });
}

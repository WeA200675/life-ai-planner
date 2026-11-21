import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:life_ai_planner/local_task_schema.dart';
import 'package:life_ai_planner/offline_day_planner.dart';
import 'package:life_ai_planner/plan_snapshot_store.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('real file-backed v3 to v4 upgrade retains tasks and plan history',
      () async {
    final directory = await Directory.systemTemp.createTemp('planner-migration-');
    final file = '${directory.path}/planner.db';
    try {
      // First process: existing version 3 data, with no plan tables.
      var db = await openDatabase(file, version: 3,
        onCreate: (database, _) async {
          await createTaskSchema(database);
          await database.insert('tasks', {
            'title': 'Important task', 'done': 0,
            'minutes': 25, 'priority': 7,
            'deadline_utc_ms': DateTime.utc(2026, 12, 1).millisecondsSinceEpoch,
          });
        },
      );
      final oldRows = await db.query('tasks');
      await db.close();

      // Second process: actual SQLite user_version upgrade and migration.
      db = await openDatabase(file, version: 4,
        onUpgrade: (database, oldVersion, newVersion) async {
          if (oldVersion < 4) await createPlanSnapshotSchema(database);
        },
      );
      try {
        expect(await db.getVersion(), 4);
        expect(await db.query('tasks'), oldRows);
        await createPlanSnapshotSchema(db); // safe retry
        final store = PlanSnapshotStore(db);
        expect(await store.latest(), isNull);
        final start = DateTime.utc(2026, 11, 20, 8);
        final end = DateTime.utc(2026, 11, 20, 18);
        final id = await store.accept(
          const DayPlan([], [], [], 600, 420, 600), start, end,
          expectedTasks: oldRows,
        );
        expect((await store.latest())?.id, id);
      } finally {
        await db.close();
      }

      // Third process: persisted history survives a second restart.
      db = await openDatabase(file, version: 4);
      try {
        expect((await PlanSnapshotStore(db).latest())?.id, 1);
        expect(await db.query('tasks'), oldRows);
      } finally {
        await db.close();
      }
    } finally {
      await directory.delete(recursive: true);
    }
  });
}

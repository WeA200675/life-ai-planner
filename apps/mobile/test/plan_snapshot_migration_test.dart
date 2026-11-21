import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:life_ai_planner/local_task_schema.dart';
import 'package:life_ai_planner/plan_snapshot_store.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('v3 to v4 preserves tasks and adds plan history', () async {
    final db = await openDatabase(inMemoryDatabasePath, version: 3,
      onCreate: (database, _) async {
        await createTaskSchema(database);
        await database.insert('tasks', {
          'title': 'Important task', 'done': 0,
          'minutes': 25, 'priority': 7,
        });
      },
    );
    try {
      await createPlanSnapshotSchema(db);
      await createPlanSnapshotSchema(db); // idempotent migration retry
      final rows = await db.query('tasks');
      expect(rows, hasLength(1));
      expect(rows.single['title'], 'Important task');
      expect(rows.single['minutes'], 25);
      expect(rows.single['priority'], 7);
      expect(await PlanSnapshotStore(db).latest(), isNull);
      final schema = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' "
        "AND name IN ('plan_snapshots', 'plan_snapshot_blocks')",
      );
      expect(schema, hasLength(2));
    } finally {
      await db.close();
    }
  });
}

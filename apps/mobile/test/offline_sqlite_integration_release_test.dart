import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/local_task_schema.dart';
import 'package:life_ai_planner/offline_day_planner.dart';
import 'package:life_ai_planner/plan_snapshot_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Release R1: real SQLite transactions with synthetic, offline-only data.
/// Never opens or modifies the user's installed application database.
void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late PlanSnapshotStore snapshots;
  final start = DateTime.utc(2026, 11, 22, 8);
  final end = DateTime.utc(2026, 11, 22, 18);

  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath, version: 4,
        onCreate: (database, version) async {
      await createTaskSchema(database);
      await createPlanSnapshotSchema(database);
    });
    snapshots = PlanSnapshotStore(db);
  });

  tearDown(() async => db.close());

  Future<List<Map<String, Object?>>> seedTasks() async {
    await db.insert('tasks', {
      'title': 'Priority', 'done': 0, 'minutes': 40, 'priority': 10
    });
    await db.insert('tasks', {
      'title': 'Normal', 'done': 0, 'minutes': 30, 'priority': 1
    });
    return db.query('tasks', orderBy: 'id ASC');
  }

  DayPlan preview(List<Map<String, Object?>> rows) {
    final tasks = rows.map((row) => DayTask(
      id: (row['id'] as int).toString(),
      minutes: row['minutes'] as int,
      priority: row['priority'] as int,
    )).toList();
    return planOfflineDay(start, end, tasks);
  }

  test('full offline preview, acceptance, history and undo preserve tasks',
      () async {
    final original = await seedTasks();
    final plan = preview(original);
    expect(plan.blocks.map((block) => block.id).toList(), ['1', '2']);
    final first = await snapshots.accept(plan, start, end,
        expectedTasks: original);
    expect((await snapshots.latest())?.id, first);
    expect((await snapshots.byId(first))?.blocks.length, 2);
    expect((await snapshots.history()).single.id, first);
    expect(await db.query('tasks', orderBy: 'id ASC'), original);
    expect(await snapshots.undoLatest(first), isTrue);
    expect(await snapshots.latest(), isNull);
    expect(await db.query('tasks', orderBy: 'id ASC'), original);
  });

  test('stale preview cannot overwrite newer task metadata', () async {
    final original = await seedTasks();
    final plan = preview(original);
    await db.update('tasks', {'minutes': 90},
        where: 'id = ?', whereArgs: [1]);
    await expectLater(
      snapshots.accept(plan, start, end, expectedTasks: original),
      throwsStateError,
    );
    expect(await snapshots.latest(), isNull);
    expect((await db.query('tasks', where: 'id = ?', whereArgs: [1]))
        .single['minutes'], 90);
  });

  test('concurrent accept with stale preview is serialized by SQLite',
      () async {
    final original = await seedTasks();
    final plan = preview(original);
    final accepted = await Future.wait([
      snapshots.accept(plan, start, end, expectedTasks: original),
      snapshots.accept(plan, start, end, expectedTasks: original),
    ]);
    expect(accepted.toSet().length, 2);
    expect((await snapshots.history()).length, 2);
    expect(await db.query('tasks', orderBy: 'id ASC'), original);
    // Concurrent accept is append-only; it is NOT a unique-request guarantee.
  });

  test('invalid overlapping blocks roll back without partial writes',
      () async {
    final original = await seedTasks();
    final invalid = DayPlan([
      DayBlock('1', start, start.add(const Duration(minutes: 40))),
      DayBlock('2', start.add(const Duration(minutes: 20)),
          start.add(const Duration(minutes: 50))),
    ], const [], const [], 600, 420, 530);
    await expectLater(
      snapshots.accept(invalid, start, end, expectedTasks: original),
      throwsArgumentError,
    );
    expect(await db.query('plan_snapshots'), isEmpty);
    expect(await db.query('plan_snapshot_blocks'), isEmpty);
    expect(await db.query('tasks', orderBy: 'id ASC'), original);
  });

  test('schema upgrade from v3 retains tasks and adds snapshot history',
      () async {
    // Exercise the same migration DDL in a private in-memory database.
    final legacy = await openDatabase(inMemoryDatabasePath, version: 3,
        onCreate: (database, version) async {
      await createTaskSchema(database);
    });
    try {
      await legacy.insert('tasks', {'title': 'Legacy', 'done': 0});
      await createPlanSnapshotSchema(legacy);
      final rows = await legacy.query('tasks');
      expect(rows.single['title'], 'Legacy');
      expect(await legacy.query('plan_snapshots'), isEmpty);
      expect(await legacy.query('plan_snapshot_blocks'), isEmpty);
    } finally {
      await legacy.close();
    }
  });
  test('same request key is idempotent across concurrent acceptance', () async {
    final original = await seedTasks();
    final plan = preview(original);
    final ids = await Future.wait([
      snapshots.accept(plan, start, end,
          expectedTasks: original, requestKey: 'synthetic-request-1'),
      snapshots.accept(plan, start, end,
          expectedTasks: original, requestKey: 'synthetic-request-1'),
    ]);
    expect(ids[0], ids[1]);
    expect((await snapshots.history()).length, 1);
    expect((await db.query('plan_accept_requests')).length, 1);
  });

  test('request key collision with different payload fails closed', () async {
    final original = await seedTasks();
    final first = preview(original);
    await snapshots.accept(first, start, end,
        expectedTasks: original, requestKey: 'collision');
    final changed = DayPlan(const [], const [], const [], 600, 420, 600);
    await expectLater(
      snapshots.accept(changed, start, end,
          expectedTasks: original, requestKey: 'collision'),
      throwsStateError,
    );
    expect((await snapshots.history()).length, 1);
  });

  test('undo removes idempotency mapping and permits safe retry', () async {
    final original = await seedTasks();
    final plan = preview(original);
    final first = await snapshots.accept(plan, start, end,
        expectedTasks: original, requestKey: 'retry-after-undo');
    expect(await snapshots.undoLatest(first), isTrue);
    expect(await db.query('plan_accept_requests'), isEmpty);
    final second = await snapshots.accept(plan, start, end,
        expectedTasks: original, requestKey: 'retry-after-undo');
    expect(second, isNot(first));
    expect((await snapshots.history()).length, 1);
  });

  test('additive schema initialization preserves existing snapshots', () async {
    final original = await seedTasks();
    final plan = preview(original);
    final first = await snapshots.accept(plan, start, end,
        expectedTasks: original);
    await createPlanSnapshotSchema(db);
    expect((await snapshots.latest())?.id, first);
    expect(await db.query('tasks', orderBy: 'id ASC'), original);
    expect(await db.query('plan_accept_requests'), isEmpty);
  });

  test('idempotency persists when the snapshot store is recreated', () async {
    final original = await seedTasks();
    final plan = preview(original);
    final first = await snapshots.accept(plan, start, end,
        expectedTasks: original, requestKey: 'persistent-key');
    final reopenedStore = PlanSnapshotStore(db);
    final retried = await reopenedStore.accept(plan, start, end,
        expectedTasks: original, requestKey: 'persistent-key');
    expect(retried, first);
    expect((await reopenedStore.history()).length, 1);
    expect((await db.query('plan_accept_requests')).single['snapshot_id'], first);
  });

  test('invalid idempotency keys fail before any database mutation', () async {
    final original = await seedTasks();
    final plan = preview(original);
    for (final key in ['', ' leading', 'trailing ', List.filled(129, 'x').join()]) {
      await expectLater(
        snapshots.accept(plan, start, end,
            expectedTasks: original, requestKey: key),
        throwsArgumentError,
      );
    }
    expect(await db.query('plan_snapshots'), isEmpty);
    expect(await db.query('plan_accept_requests'), isEmpty);
  });

  test('request idempotency survives closing and reopening a real SQLite file',
      () async {
    final directory = await Directory.systemTemp.createTemp('planner-r1-');
    final file = '${directory.path}/planner-test.db';
    Database? disk;
    try {
      disk = await openDatabase(file, version: 4,
          onCreate: (database, version) async {
        await createTaskSchema(database);
        await createPlanSnapshotSchema(database);
      });
      await disk.insert('tasks', {
        'title': 'Synthetic', 'done': 0, 'minutes': 30, 'priority': 5
      });
      final original = await disk.query('tasks');
      final plan = planOfflineDay(start, end, [
        DayTask(id: (original.single['id'] as int).toString(),
            minutes: 30, priority: 5),
      ]);
      final first = await PlanSnapshotStore(disk).accept(plan, start, end,
          expectedTasks: original, requestKey: 'file-reopen-key');
      await disk.close();
      disk = null;
      disk = await openDatabase(file, version: 4,
          onOpen: createPlanSnapshotSchema);
      final second = await PlanSnapshotStore(disk).accept(plan, start, end,
          expectedTasks: original, requestKey: 'file-reopen-key');
      expect(second, first);
      expect((await PlanSnapshotStore(disk).history()).length, 1);
      expect(await disk.query('tasks'), original);
    } finally {
      if (disk != null) await disk.close();
      await directory.delete(recursive: true);
    }
  });

  test('real SQLite v3 to v4 migration retains task and supports acceptance',
      () async {
    final directory = await Directory.systemTemp.createTemp('planner-upgrade-');
    final file = '${directory.path}/upgrade.db';
    Database? disk;
    try {
      disk = await openDatabase(file, version: 3,
          onCreate: (database, version) async {
        await createTaskSchema(database);
      });
      await disk.insert('tasks', {
        'title': 'Legacy synthetic task', 'done': 0,
        'minutes': 25, 'priority': 8
      });
      final before = await disk.query('tasks');
      await disk.close();
      disk = null;

      var upgradeCalled = false;
      disk = await openDatabase(file, version: 4,
          onUpgrade: (database, oldVersion, newVersion) async {
        expect(oldVersion, 3);
        expect(newVersion, 4);
        upgradeCalled = true;
        await createPlanSnapshotSchema(database);
      },
          onOpen: createPlanSnapshotSchema);
      expect(upgradeCalled, isTrue);
      expect(await disk.query('tasks'), before);
      final plan = planOfflineDay(start, end, [
        DayTask(id: (before.single['id'] as int).toString(),
            minutes: 25, priority: 8),
      ]);
      final id = await PlanSnapshotStore(disk).accept(plan, start, end,
          expectedTasks: before, requestKey: 'upgrade-test-key');
      expect((await PlanSnapshotStore(disk).latest())?.id, id);
      expect(await disk.query('tasks'), before);
    } finally {
      if (disk != null) await disk.close();
      await directory.delete(recursive: true);
    }
  });

}

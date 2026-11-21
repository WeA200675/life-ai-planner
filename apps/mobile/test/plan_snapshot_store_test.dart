import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:life_ai_planner/plan_snapshot_store.dart';
import 'package:life_ai_planner/offline_day_planner.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late PlanSnapshotStore store;
  final start = DateTime.utc(2026, 11, 20, 8);
  final end = DateTime.utc(2026, 11, 20, 18);

  setUp(() async {
    db = await openDatabase(inMemoryDatabasePath);
    await createPlanSnapshotSchema(db);
    store = PlanSnapshotStore(db);
  });

  tearDown(() async => db.close());

  DayPlan plan(String id) => DayPlan(
    [DayBlock(id, start, start.add(const Duration(minutes: 30)))],
    const [], const [], 600, 420, 570,
  );

  test('accepted plan survives store recreation and preserves task rows', () async {
    await db.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT)');
    await db.insert('tasks', {'id': 1, 'title': 'Unchanged'});
    final id = await store.accept(plan('1'), start, end);
    final restored = await PlanSnapshotStore(db).latest();
    expect(restored?.id, id);
    expect(restored?.blocks.single.id, '1');
    expect(restored?.blocks.single.start, start);
    expect((await db.query('tasks')).single['title'], 'Unchanged');
  });

  test('undo rejects stale version and restores prior snapshot', () async {
    final first = await store.accept(plan('first'), start, end);
    final second = await store.accept(plan('second'), start, end);
    expect(await store.undoLatest(first), isFalse);
    expect((await store.latest())?.id, second);
    expect(await store.undoLatest(second), isTrue);
    expect((await store.latest())?.id, first);
    expect(await store.undoLatest(first), isTrue);
    expect(await store.latest(), isNull);
  });

  test('invalid plan never creates a snapshot', () async {
    final invalid = DayPlan(
      [DayBlock('bad', end, end.add(const Duration(minutes: 1)))],
      const [], const [], 600, 420, 600,
    );
    await expectLater(store.accept(invalid, start, end), throwsArgumentError);
    expect(await store.latest(), isNull);
  });

  test('empty plan can be saved and undone', () async {
    final id = await store.accept(
      const DayPlan([], [], [], 600, 420, 600), start, end,
    );
    expect((await store.latest())?.blocks, isEmpty);
    expect(await store.undoLatest(id), isTrue);
  });
  test('stale confirmation is rejected without creating a plan', () async {
    await db.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT)');
    await db.insert('tasks', {'id': 1, 'title': 'Original'});
    final previewRows = await db.query('tasks');
    await db.update('tasks', {'title': 'Changed'}, where: 'id = ?', whereArgs: [1]);
    await expectLater(
      store.accept(plan('1'), start, end, expectedTasks: previewRows),
      throwsStateError,
    );
    expect(await store.latest(), isNull);
    expect((await db.query('tasks')).single['title'], 'Changed');
  });

  test('unchanged task snapshot is accepted regardless of column ordering', () async {
    await db.execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT)');
    await db.insert('tasks', {'id': 1, 'title': 'Stable'});
    final id = await store.accept(plan('1'), start, end,
      expectedTasks: [{'title': 'Stable', 'id': 1}]);
    expect((await store.latest())?.id, id);
  });

  test('fingerprint is independent of row order', () {
    final first = <Map<String, Object?>>[
      {'id': 2, 'title': 'B'}, {'id': 1, 'title': 'A'},
    ];
    final second = <Map<String, Object?>>[
      {'title': 'A', 'id': 1}, {'title': 'B', 'id': 2},
    ];
    expect(taskRowsFingerprint(first), taskRowsFingerprint(second));
  });

  test('overlapping or duplicate blocks are rejected atomically', () async {
    for (final blocks in <List<DayBlock>>[
      [
        DayBlock('a', start, start.add(const Duration(minutes: 30))),
        DayBlock('b', start.add(const Duration(minutes: 10)),
            start.add(const Duration(minutes: 40))),
      ],
      [
        DayBlock('same', start, start.add(const Duration(minutes: 20))),
        DayBlock('same', start.add(const Duration(minutes: 20)),
            start.add(const Duration(minutes: 40))),
      ],
    ]) {
      await expectLater(
        store.accept(DayPlan(blocks, const [], const [], 600, 420, 500),
            start, end),
        throwsArgumentError,
      );
    }
    expect(await store.latest(), isNull);
  });

  test('impossible capacity is rejected without persistence', () async {
    await expectLater(
      store.accept(const DayPlan([], [], [], 600, 700, 0), start, end),
      throwsArgumentError,
    );
    expect(await store.latest(), isNull);
  });

  test('history is newest first, paginated and read-only', () async {
    final ids = <int>[];
    for (var i = 0; i < 5; i++) {
      ids.add(await store.accept(plan('task-$i'), start, end));
    }
    final firstPage = await store.history(limit: 2);
    final secondPage = await store.history(limit: 2, offset: 2);
    expect(firstPage.map((e) => e.id), [ids[4], ids[3]]);
    expect(secondPage.map((e) => e.id), [ids[2], ids[1]]);
    expect(firstPage.singleWhere((e) => e.id == ids[4]).blocks, isEmpty);
    expect((await store.byId(ids[2]))?.blocks.single.id, 'task-2');
    expect((await store.latest())?.id, ids[4]);
  });

  test('history rejects unbounded queries and invalid identifiers', () async {
    await expectLater(store.history(limit: 101), throwsArgumentError);
    await expectLater(store.history(limit: 0), throwsArgumentError);
    await expectLater(store.history(offset: -1), throwsArgumentError);
    await expectLater(store.byId(0), throwsArgumentError);
    expect(await store.byId(99999), isNull);
  });

  test('history traverses more than thirty versions without duplication', () async {
    final ids = <int>[];
    for (var i = 0; i < 67; i++) {
      ids.add(await store.accept(plan('task-$i'), start, end));
    }
    final pages = <SavedPlan>[];
    for (var offset = 0; ; offset += 30) {
      final page = await store.history(limit: 30, offset: offset);
      pages.addAll(page);
      if (page.length < 30) break;
    }
    expect(pages.length, 67);
    expect(pages.map((p) => p.id).toSet().length, 67);
    expect(pages.first.id, ids.last);
    expect(pages.last.id, ids.first);
    expect((await store.latest())?.id, ids.last);
  });

}

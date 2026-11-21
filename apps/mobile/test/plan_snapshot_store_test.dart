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
}

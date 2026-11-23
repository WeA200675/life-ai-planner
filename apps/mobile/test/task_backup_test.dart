import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/local_task_schema.dart';
import 'package:life_ai_planner/task_backup.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final task = <String, Object?>{
    'id': 1, 'title': 'Offline task', 'done': 0,
    'minutes': 25, 'priority': 7, 'deadline_utc_ms': null,
  };

  test('versioned export round-trips every task field deterministically', () {
    final backup = encodeTaskBackup([task]);
    final decoded = decodeTaskBackup(backup);
    expect(decoded.tasks, [task]);
    expect(encodeTaskBackup(decoded.tasks), backup);
    expect(jsonDecode(backup)['schema_version'], 1);
  });

  test('rejects duplicate ids, malformed fields and unsupported versions', () {
    expect(() => encodeTaskBackup([task, task]), throwsFormatException);
    expect(() => encodeTaskBackup([
      {...task, 'priority': 11},
    ]), throwsFormatException);
    expect(() => encodeTaskBackup([
      {...task, 'extra': 'unexpected'},
    ]), throwsFormatException);
    final payload = jsonDecode(encodeTaskBackup([task])) as Map<String, dynamic>;
    payload['schema_version'] = 999;
    expect(() => decodeTaskBackup(jsonEncode(payload)), throwsFormatException);
    payload['schema_version'] = 1;
    payload['tasks'] = [task, task];
    expect(() => decodeTaskBackup(jsonEncode(payload)), throwsFormatException);
  });

  test('restore is atomic and rejects stale preview', () async {
    final db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, _) => createTaskSchema(db));
    try {
      await db.insert('tasks', task);
      final before = await db.query('tasks');
      final backup = decodeTaskBackup(encodeTaskBackup([
        {...task, 'title': 'Restored'},
      ]));
      await db.update('tasks', {'title': 'Changed'}, where: 'id = ?',
          whereArgs: [1]);
      await expectLater(
        restoreTaskBackup(db, backup, expectedTasks: before),
        throwsStateError,
      );
      expect((await db.query('tasks')).single['title'], 'Changed');
      final latest = await db.query('tasks');
      expect(await restoreTaskBackup(db, backup, expectedTasks: latest), 1);
      expect((await db.query('tasks')).single['title'], 'Restored');
    } finally {
      await db.close();
    }
  });

  test('empty backup can clear tasks only when explicitly restored', () async {
    final db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, _) => createTaskSchema(db));
    try {
      await db.insert('tasks', task);
      final before = await db.query('tasks');
      final empty = decodeTaskBackup(encodeTaskBackup([]));
      expect(await db.query('tasks'), hasLength(1));
      expect(await restoreTaskBackup(db, empty, expectedTasks: before), 0);
      expect(await db.query('tasks'), isEmpty);
    } finally {
      await db.close();
    }
  });
  test('restore rolls back every deletion if an insert fails', () async {
    final db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, _) => createTaskSchema(db));
    try {
      await db.insert('tasks', task);
      await db.execute('CREATE TRIGGER block_restore BEFORE INSERT ON tasks '
          "WHEN NEW.title = 'Blocked' BEGIN SELECT RAISE(ABORT, 'blocked'); END");
      final before = await db.query('tasks');
      final replacement = decodeTaskBackup(encodeTaskBackup([
        {...task, 'id': 2, 'title': 'Allowed'},
        {...task, 'id': 3, 'title': 'Blocked'},
      ]));
      await expectLater(
        restoreTaskBackup(db, replacement, expectedTasks: before),
        throwsA(isA<Exception>()),
      );
      expect(await db.query('tasks'), before);
    } finally {
      await db.close();
    }
  });

  test('restore rejects a mutated backup before deleting rows', () async {
    final db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, _) => createTaskSchema(db));
    try {
      await db.insert('tasks', task);
      final before = await db.query('tasks');
      final backup = TaskBackup([{...task, 'done': 7}]);
      await expectLater(
        restoreTaskBackup(db, backup, expectedTasks: before),
        throwsFormatException,
      );
      expect(await db.query('tasks'), before);
    } finally {
      await db.close();
    }
  });

  test('identical restore never fires delete or update triggers', () async {
    final db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, _) => createTaskSchema(db));
    try {
      await db.insert('tasks', task);
      await db.execute('CREATE TRIGGER forbid_task_delete BEFORE DELETE ON tasks '
          "BEGIN SELECT RAISE(ABORT, 'unexpected delete'); END");
      await db.execute('CREATE TRIGGER forbid_task_update BEFORE UPDATE ON tasks '
          "BEGIN SELECT RAISE(ABORT, 'unexpected update'); END");
      final before = await db.query('tasks');
      final backup = decodeTaskBackup(encodeTaskBackup(before));
      expect(await restoreTaskBackup(db, backup, expectedTasks: before), 1);
      expect(await db.query('tasks'), before);
    } finally {
      await db.close();
    }
  });

  test('changed restore updates in place without deleting the task', () async {
    final db = await openDatabase(inMemoryDatabasePath, version: 1,
        onCreate: (db, _) => createTaskSchema(db));
    try {
      await db.insert('tasks', task);
      await db.execute('CREATE TRIGGER forbid_task_delete BEFORE DELETE ON tasks '
          "BEGIN SELECT RAISE(ABORT, 'unexpected delete'); END");
      final before = await db.query('tasks');
      final backup = decodeTaskBackup(encodeTaskBackup([
        {...task, 'title': 'Updated in place'},
      ]));
      expect(await restoreTaskBackup(db, backup, expectedTasks: before), 1);
      final after = (await db.query('tasks')).single;
      expect(after['id'], task['id']);
      expect(after['title'], 'Updated in place');
    } finally {
      await db.close();
    }
  });

  test('backup limit measures UTF-8 bytes, not UTF-16 characters', () {
    // 3 million Euro symbols occupy 9 MB in UTF-8 but only 3 million
    // UTF-16 code units. Reject before parsing an oversized JSON payload.
    final oversized = '{"format":"' + ('€' * 3000000) + '"}';
    expect(oversized.length, lessThan(maxTaskBackupBytes));
    expect(() => decodeTaskBackup(oversized), throwsFormatException);
  });

  test('export rejects valid Unicode tasks exceeding the byte cap', () {
    final rows = List.generate(8000, (index) => {
      ...task,
      'id': index + 1,
      'title': '€' * 400,
    });
    expect(() => encodeTaskBackup(rows), throwsFormatException);
  });

  test('backup rejects oversized input before decoding', () {
    expect(() => decodeTaskBackup(' ' * (8 * 1024 * 1024 + 1)),
        throwsFormatException);
  });

  test('restore preview reports exact additions, changes and removals', () {
    final current = [
      task,
      {...task, 'id': 2, 'title': 'Old title'},
      {...task, 'id': 3, 'title': 'Removed'},
    ];
    final backup = decodeTaskBackup(encodeTaskBackup([
      task,
      {...task, 'id': 2, 'title': 'New title'},
      {...task, 'id': 4, 'title': 'Added'},
    ]));
    final impact = previewTaskRestore(current, backup);
    expect(impact.currentCount, 3);
    expect(impact.backupCount, 3);
    expect(impact.added, 1);
    expect(impact.removed, 1);
    expect(impact.changed, 1);
    expect(impact.unchanged, 1);
    expect(current[1]['title'], 'Old title');
  });

  test('restore preview handles empty backups without modifying tasks', () {
    final impact = previewTaskRestore([task],
        decodeTaskBackup(encodeTaskBackup([])));
    expect(impact.removed, 1);
    expect(impact.added, 0);
    expect(impact.changed, 0);
  });

}

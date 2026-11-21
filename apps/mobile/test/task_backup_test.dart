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
}

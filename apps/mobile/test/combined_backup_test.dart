import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/combined_backup.dart';
import 'package:life_ai_planner/local_task_schema.dart';
import 'package:life_ai_planner/plan_snapshot_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('combined export validates and preserves tasks and history', () async {
    final db = await openDatabase(inMemoryDatabasePath);
    try {
      await createTaskSchema(db);
      await createPlanSnapshotSchema(db);
      await db.insert('tasks', {'id': 1, 'title': 'Synthetic', 'done': 0});
      await db.insert('plan_snapshots', {
        'id': 1, 'created_utc_ms': 1000, 'window_start_utc_ms': 2000,
        'window_end_utc_ms': 5000, 'budget_minutes': 20,
        'reserved_minutes': 10,
      });
      await db.insert('plan_snapshot_blocks', {
        'snapshot_id': 1, 'position': 0, 'task_id': '1',
        'start_utc_ms': 2500, 'end_utc_ms': 3000,
      });
      final output = await exportCombinedBackup(db);
      validateCombinedBackup(output);
      expect(await exportCombinedBackup(db), output);
      final decoded = jsonDecode(output) as Map<String, dynamic>;
      expect(decoded['schema_version'], 1);
      expect((decoded['plan_history']['blocks'] as List), hasLength(1));
      expect((await db.query('tasks')).single['title'], 'Synthetic');

      final corrupted = jsonDecode(output) as Map<String, dynamic>;
      corrupted['tasks']['tasks'] = [];
      expect(() => validateCombinedBackup(jsonEncode(corrupted)),
          throwsFormatException);
      expect((await db.query('tasks')).single['title'], 'Synthetic');
    } finally {
      await db.close();
    }
  });

  test('orphan history fails export without changing existing rows', () async {
    final db = await openDatabase(inMemoryDatabasePath);
    try {
      await createTaskSchema(db);
      await createPlanSnapshotSchema(db);
      await db.insert('plan_snapshots', {
        'id': 1, 'created_utc_ms': 1000, 'window_start_utc_ms': 2000,
        'window_end_utc_ms': 5000, 'budget_minutes': 20,
        'reserved_minutes': 10,
      });
      await db.insert('plan_snapshot_blocks', {
        'snapshot_id': 1, 'position': 0, 'task_id': '999',
        'start_utc_ms': 2500, 'end_utc_ms': 3000,
      });
      await expectLater(exportCombinedBackup(db), throwsFormatException);
      expect(await db.query('plan_snapshot_blocks'), hasLength(1));
    } finally {
      await db.close();
    }
  });
  test('atomic combined restore preserves IDs and refuses nonempty target', () async {
    final directory = Directory.systemTemp.createTempSync('combined-restore-');
    final source = await openDatabase('${directory.path}/source.db');
    final target = await openDatabase('${directory.path}/target.db');
    try {
      for (final db in [source, target]) {
        await createTaskSchema(db);
        await createPlanSnapshotSchema(db);
      }
      await source.insert('tasks', {
        'id': 7, 'title': 'Synthetic', 'done': 0,
      });
      await source.insert('plan_snapshots', {
        'id': 4, 'created_utc_ms': 1000, 'window_start_utc_ms': 2000,
        'window_end_utc_ms': 5000, 'budget_minutes': 20,
        'reserved_minutes': 10,
      });
      await source.insert('plan_snapshot_blocks', {
        'snapshot_id': 4, 'position': 0, 'task_id': '7',
        'start_utc_ms': 2500, 'end_utc_ms': 3000,
      });
      final archive = await exportCombinedBackup(source);
      final restored = await restoreCombinedIntoEmptyDatabase(target, archive);
      expect(restored.tasks, 1);
      expect(restored.snapshots, 1);
      expect((await target.query('tasks')).single['id'], 7);
      expect((await target.query('plan_snapshots')).single['id'], 4);
      expect((await target.query('plan_snapshot_blocks')).single['task_id'], '7');
      await expectLater(restoreCombinedIntoEmptyDatabase(target, archive),
          throwsStateError);
      expect(await target.query('tasks'), hasLength(1));
    } finally {
      await source.close();
      await target.close();
      directory.deleteSync(recursive: true);
    }
  });

  test('combined restore rolls back tasks when history insert fails', () async {
    final directory = Directory.systemTemp.createTempSync('combined-rollback-');
    final source = await openDatabase('${directory.path}/source.db');
    final target = await openDatabase('${directory.path}/target.db');
    try {
      for (final db in [source, target]) {
        await createTaskSchema(db);
        await createPlanSnapshotSchema(db);
      }
      await source.insert('tasks', {'id': 2, 'title': 'Synthetic', 'done': 0});
      await source.insert('plan_snapshots', {
        'id': 3, 'created_utc_ms': 1000, 'window_start_utc_ms': 2000,
        'window_end_utc_ms': 5000, 'budget_minutes': 20,
        'reserved_minutes': 10,
      });
      final archive = await exportCombinedBackup(source);
      await target.execute('CREATE TRIGGER reject_history BEFORE INSERT '
          'ON plan_snapshots BEGIN SELECT RAISE(ABORT, "blocked"); END;');
      await expectLater(restoreCombinedIntoEmptyDatabase(target, archive),
          throwsA(isA<Exception>()));
      expect(await target.query('tasks'), isEmpty);
      expect(await target.query('plan_snapshots'), isEmpty);
    } finally {
      await source.close();
      await target.close();
      directory.deleteSync(recursive: true);
    }
  });

}

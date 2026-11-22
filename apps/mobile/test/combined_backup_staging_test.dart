import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/combined_backup.dart';
import 'package:life_ai_planner/combined_backup_staging.dart';
import 'package:life_ai_planner/local_task_schema.dart';
import 'package:life_ai_planner/plan_snapshot_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('stage creates verified separate SQLite file without touching source',
      () async {
    final dir = await Directory.systemTemp.createTemp('stage-success-');
    final source = await openDatabase('${dir.path}/active.db');
    try {
      await createTaskSchema(source);
      await createPlanSnapshotSchema(source);
      await source.insert('tasks', {'id': 8, 'title': 'Synthetic', 'done': 0});
      final archive = await exportCombinedBackup(source);
      final candidate = '${dir.path}/candidate.db';
      final counts = await stageCombinedBackup(archive, candidate);
      expect(counts.tasks, 1);
      expect(counts.snapshots, 0);
      expect(await File(candidate).exists(), isTrue);
      final staged = await openDatabase(candidate);
      try {
        expect((await staged.query('tasks')).single['id'], 8);
      } finally {
        await staged.close();
      }
      expect((await source.query('tasks')).single['title'], 'Synthetic');
      await expectLater(stageCombinedBackup(archive, candidate),
          throwsStateError);
      expect((await source.query('tasks')).single['title'], 'Synthetic');
    } finally {
      await source.close();
      await dir.delete(recursive: true);
    }
  });

  test('invalid archive leaves no candidate file', () async {
    final dir = await Directory.systemTemp.createTemp('stage-invalid-');
    try {
      final candidate = '${dir.path}/candidate.db';
      await expectLater(stageCombinedBackup('{}', candidate),
          throwsFormatException);
      expect(await File(candidate).exists(), isFalse);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('existing candidate remains untouched even for valid archive',
      () async {
    final dir = await Directory.systemTemp.createTemp('stage-existing-');
    final source = await openDatabase('${dir.path}/source.db');
    try {
      await createTaskSchema(source);
      await createPlanSnapshotSchema(source);
      final archive = await exportCombinedBackup(source);
      final candidate = File('${dir.path}/candidate.db');
      await candidate.writeAsString('DO NOT OVERWRITE');
      await expectLater(stageCombinedBackup(archive, candidate.path),
          throwsStateError);
      expect(await candidate.readAsString(), 'DO NOT OVERWRITE');
    } finally {
      await source.close();
      await dir.delete(recursive: true);
    }
  });
  test('staged verification detects orphaned snapshot block foreign keys',
      () async {
    final dir = await Directory.systemTemp.createTemp('stage-fk-check-');
    final db = await openDatabase('${dir.path}/orphan.db');
    try {
      await createTaskSchema(db);
      await createPlanSnapshotSchema(db);
      // Simulate a damaged legacy database created without FK enforcement.
      await db.insert('plan_snapshot_blocks', {
        'snapshot_id': 987654,
        'position': 0,
        'task_id': '1',
        'start_utc_ms': 1000,
        'end_utc_ms': 2000,
      });
      final integrity = await db.rawQuery('PRAGMA integrity_check');
      expect(integrity.single.values.single, 'ok');
      await expectLater(verifyStagedDatabase(db), throwsStateError);
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });

  test('staged verification accepts consistent empty schema', () async {
    final dir = await Directory.systemTemp.createTemp('stage-fk-valid-');
    final db = await openDatabase('${dir.path}/valid.db');
    try {
      await createTaskSchema(db);
      await createPlanSnapshotSchema(db);
      await verifyStagedDatabase(db);
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });

  test('semantic verification detects modified task content after staging',
      () async {
    final dir = await Directory.systemTemp.createTemp('stage-content-');
    final source = await openDatabase('${dir.path}/source.db');
    final staged = await openDatabase('${dir.path}/staged.db');
    try {
      for (final db in [source, staged]) {
        await createTaskSchema(db);
        await createPlanSnapshotSchema(db);
        await db.insert('tasks', {'id': 9, 'title': 'Original', 'done': 0});
      }
      final archive = await exportCombinedBackup(source);
      await verifyStagedArchive(staged, archive);
      await staged.update('tasks', {'title': 'Altered'},
          where: 'id = ?', whereArgs: [9]);
      // SQLite remains structurally sound, but semantic comparison must fail.
      await verifyStagedDatabase(staged);
      await expectLater(verifyStagedArchive(staged, archive), throwsStateError);
      expect((await source.query('tasks')).single['title'], 'Original');
    } finally {
      await source.close();
      await staged.close();
      await dir.delete(recursive: true);
    }
  });

  test('semantic verification rejects unexpected extra staged task',
      () async {
    final dir = await Directory.systemTemp.createTemp('stage-extra-');
    final source = await openDatabase('${dir.path}/source.db');
    final staged = await openDatabase('${dir.path}/staged.db');
    try {
      for (final db in [source, staged]) {
        await createTaskSchema(db);
        await createPlanSnapshotSchema(db);
      }
      final archive = await exportCombinedBackup(source);
      await staged.insert('tasks', {'id': 2, 'title': 'Unexpected', 'done': 0});
      await expectLater(verifyStagedArchive(staged, archive), throwsStateError);
    } finally {
      await source.close();
      await staged.close();
      await dir.delete(recursive: true);
    }
  });

}

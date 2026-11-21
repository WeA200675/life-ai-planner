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
}

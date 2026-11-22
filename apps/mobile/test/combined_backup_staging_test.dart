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

  test('staged archive survives independent read-only reopen', () async {
    final dir = await Directory.systemTemp.createTemp('stage-durable-');
    final source = await openDatabase('${dir.path}/source.db');
    try {
      await createTaskSchema(source);
      await createPlanSnapshotSchema(source);
      await source.insert('tasks', {
        'id': 51, 'title': 'Synthetic durable task', 'done': 0,
      });
      final archive = await exportCombinedBackup(source);
      final path = '${dir.path}/candidate.db';
      await stageCombinedBackup(archive, path);
      final reader = await databaseFactoryFfi.openDatabase(path,
          options: OpenDatabaseOptions(readOnly: true));
      try {
        await verifyStagedDatabase(reader);
        await verifyStagedArchive(reader, archive);
        expect((await reader.query('tasks')).single['id'], 51);
      } finally {
        await reader.close();
      }
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

  test('checkpoint preserves staged data after closing and reopening WAL DB',
      () async {
    final dir = await Directory.systemTemp.createTemp('stage-wal-');
    final path = '${dir.path}/candidate.db';
    var db = await openDatabase(path);
    try {
      await createTaskSchema(db);
      await createPlanSnapshotSchema(db);
      await db.rawQuery('PRAGMA journal_mode=WAL');
      await db.insert('tasks', {'id': 17, 'title': 'Synthetic WAL', 'done': 0});
      await checkpointStagedDatabase(db);
      await db.close();
      db = await openDatabase(path);
      expect((await db.query('tasks')).single['title'], 'Synthetic WAL');
      await verifyStagedDatabase(db);
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });

  test('checkpoint is safe for non-WAL staged databases', () async {
    final dir = await Directory.systemTemp.createTemp('stage-journal-');
    final db = await openDatabase('${dir.path}/candidate.db');
    try {
      await createTaskSchema(db);
      await createPlanSnapshotSchema(db);
      await db.rawQuery('PRAGMA journal_mode=DELETE');
      await checkpointStagedDatabase(db);
      await verifyStagedDatabase(db);
    } finally {
      await db.close();
      await dir.delete(recursive: true);
    }
  });

  test('orphan SQLite sidecar blocks staging without changing it', () async {
    final dir = await Directory.systemTemp.createTemp('stage-sidecar-');
    final source = await openDatabase('${dir.path}/source.db');
    try {
      await createTaskSchema(source);
      await createPlanSnapshotSchema(source);
      final archive = await exportCombinedBackup(source);
      for (final suffix in ['-wal', '-shm', '-journal']) {
        final candidate = '${dir.path}/candidate.db';
        final sidecar = File('$candidate$suffix');
        await sidecar.writeAsString('PRESERVE SIDECAR');
        await expectLater(stageCombinedBackup(archive, candidate),
            throwsStateError);
        expect(await sidecar.readAsString(), 'PRESERVE SIDECAR');
        expect(await File(candidate).exists(), isFalse);
        await sidecar.delete();
      }
    } finally {
      await source.close();
      await dir.delete(recursive: true);
    }
  });

  test('symlink staging parent is rejected without writing target', () async {
    if (Platform.isWindows) return; // Symlink privileges differ on Windows.
    final dir = await Directory.systemTemp.createTemp('stage-link-parent-');
    final source = await openDatabase('${dir.path}/source.db');
    try {
      await createTaskSchema(source);
      await createPlanSnapshotSchema(source);
      final archive = await exportCombinedBackup(source);
      final actual = await Directory('${dir.path}/real').create();
      final alias = Link('${dir.path}/alias');
      await alias.create(actual.path);
      await expectLater(
          stageCombinedBackup(archive, '${alias.path}/candidate.db'),
          throwsStateError);
      expect(await File('${actual.path}/candidate.db').exists(), isFalse);
    } finally {
      await source.close();
      await dir.delete(recursive: true);
    }
  });

  test('dangling symlink candidate is rejected and preserved', () async {
    if (Platform.isWindows) return;
    final dir = await Directory.systemTemp.createTemp('stage-link-file-');
    final source = await openDatabase('${dir.path}/source.db');
    try {
      await createTaskSchema(source);
      await createPlanSnapshotSchema(source);
      final archive = await exportCombinedBackup(source);
      final candidate = Link('${dir.path}/candidate.db');
      await candidate.create('${dir.path}/missing-target.db');
      await expectLater(stageCombinedBackup(archive, candidate.path),
          throwsStateError);
      expect(await candidate.exists(), isTrue);
      expect(await File('${dir.path}/missing-target.db').exists(), isFalse);
    } finally {
      await source.close();
      await dir.delete(recursive: true);
    }
  });

  test('dangling symlink sidecars reject staging and remain untouched',
      () async {
    if (Platform.isWindows) return;
    final dir = await Directory.systemTemp.createTemp('stage-link-sidecar-');
    final source = await openDatabase('${dir.path}/source.db');
    try {
      await createTaskSchema(source);
      await createPlanSnapshotSchema(source);
      final archive = await exportCombinedBackup(source);
      final candidate = '${dir.path}/candidate.db';
      for (final suffix in ['-wal', '-shm', '-journal']) {
        final target = '${dir.path}/absent$suffix';
        final sidecar = Link('$candidate$suffix');
        await sidecar.create(target);
        await expectLater(stageCombinedBackup(archive, candidate),
            throwsStateError);
        expect(await sidecar.exists(), isTrue);
        expect(await File(target).exists(), isFalse);
        expect(await File(candidate).exists(), isFalse);
        await sidecar.delete();
      }
    } finally {
      await source.close();
      await dir.delete(recursive: true);
    }
  });

  test('nested ancestor symlink rejects staging without target writes',
      () async {
    if (Platform.isWindows) return;
    final dir = await Directory.systemTemp.createTemp('stage-nested-link-');
    final source = await openDatabase('${dir.path}/source.db');
    try {
      await createTaskSchema(source);
      await createPlanSnapshotSchema(source);
      final archive = await exportCombinedBackup(source);
      final actual = await Directory('${dir.path}/real/inner')
          .create(recursive: true);
      final alias = Link('${dir.path}/alias');
      await alias.create(Directory('${dir.path}/real').path);
      final candidate = '${alias.path}/inner/candidate.db';
      await expectLater(stageCombinedBackup(archive, candidate),
          throwsStateError);
      expect(await File('${actual.path}/candidate.db').exists(), isFalse);
      expect(await alias.exists(), isTrue);
    } finally {
      await source.close();
      await dir.delete(recursive: true);
    }
  });

  test('activation preflight accepts intact staged candidate read-only',
      () async {
    final dir = await Directory.systemTemp.createTemp('preflight-valid-');
    final source = await openDatabase('${dir.path}/source.db');
    try {
      await createTaskSchema(source);
      await createPlanSnapshotSchema(source);
      await source.insert('tasks', {'id': 101, 'title': 'Synthetic', 'done': 0});
      final archive = await exportCombinedBackup(source);
      final path = '${dir.path}/candidate.db';
      await stageCombinedBackup(archive, path);
      await inspectStagedCandidate(archive, path);
      expect((await source.query('tasks')).single['title'], 'Synthetic');
    } finally {
      await source.close();
      await dir.delete(recursive: true);
    }
  });

  test('activation preflight rejects modified staged content and sidecars',
      () async {
    final dir = await Directory.systemTemp.createTemp('preflight-reject-');
    final source = await openDatabase('${dir.path}/source.db');
    try {
      await createTaskSchema(source);
      await createPlanSnapshotSchema(source);
      await source.insert('tasks', {'id': 102, 'title': 'Original', 'done': 0});
      final archive = await exportCombinedBackup(source);
      final path = '${dir.path}/candidate.db';
      await stageCombinedBackup(archive, path);
      final sidecar = File('${path}-wal');
      await sidecar.writeAsString('DO NOT REMOVE');
      await expectLater(inspectStagedCandidate(archive, path), throwsStateError);
      expect(await sidecar.readAsString(), 'DO NOT REMOVE');
      await sidecar.delete();
      final candidate = await openDatabase(path);
      await candidate.update('tasks', {'title': 'Tampered'},
          where: 'id = ?', whereArgs: [102]);
      await candidate.close();
      await expectLater(inspectStagedCandidate(archive, path), throwsStateError);
      expect((await source.query('tasks')).single['title'], 'Original');
    } finally {
      await source.close();
      await dir.delete(recursive: true);
    }
  });

  test('closed active database preflight is read-only', () async {
    final dir = await Directory.systemTemp.createTemp('active-preflight-');
    final path = '${dir.path}/active.db';
    final writer = await openDatabase(path);
    try {
      await createTaskSchema(writer);
      await createPlanSnapshotSchema(writer);
      await writer.insert('tasks', {'id': 6, 'title': 'Synthetic', 'done': 0});
    } finally {
      await writer.close();
    }
    try {
      await inspectClosedActiveDatabase(path);
      final reader = await databaseFactoryFfi.openDatabase(path,
          options: OpenDatabaseOptions(readOnly: true, singleInstance: false));
      try {
        expect((await reader.query('tasks')).single['title'], 'Synthetic');
      } finally {
        await reader.close();
      }
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('active preflight rejects recovery artifacts without deleting them',
      () async {
    final dir = await Directory.systemTemp.createTemp('active-artifact-');
    final path = '${dir.path}/active.db';
    final db = await openDatabase(path);
    await createTaskSchema(db);
    await createPlanSnapshotSchema(db);
    await db.close();
    try {
      for (final suffix in ['-wal', '-shm', '-journal',
          '.restore-backup', '.restore-marker', '.restore-pending']) {
        final artifact = File('$path$suffix');
        await artifact.writeAsString('KEEP');
        await expectLater(inspectClosedActiveDatabase(path), throwsStateError);
        expect(await artifact.readAsString(), 'KEEP');
        await artifact.delete();
      }
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('active preflight rejects missing and invalid database paths',
      () async {
    final dir = await Directory.systemTemp.createTemp('active-missing-');
    try {
      await expectLater(inspectClosedActiveDatabase('${dir.path}/missing.db'),
          throwsStateError);
      await expectLater(inspectClosedActiveDatabase('${dir.path}/bad.txt'),
          throwsArgumentError);
      expect(await File('${dir.path}/missing.db').exists(), isFalse);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('restore pair rejects active hard-link alias without changing files',
      () async {
    if (Platform.isWindows) return; // Hard-link behavior differs by runner.
    final dir = await Directory.systemTemp.createTemp('pair-hardlink-');
    final path = '${dir.path}/active.db';
    final db = await openDatabase(path);
    try {
      await createTaskSchema(db);
      await createPlanSnapshotSchema(db);
      await db.insert('tasks', {'id': 41, 'title': 'Keep', 'done': 0});
      final archive = await exportCombinedBackup(db);
      await db.close();
      final alias = '${dir.path}/candidate.db';
      await Link(alias).create(path); // Symlink alias is also prohibited.
      await expectLater(inspectRestorePair(archive, path, alias),
          throwsStateError);
      expect(await File(path).exists(), isTrue);
      expect(await Link(alias).exists(), isTrue);
    } finally {
      if (db.isOpen) await db.close();
      await dir.delete(recursive: true);
    }
  });

  test('restore pair accepts separate verified databases read-only',
      () async {
    final dir = await Directory.systemTemp.createTemp('pair-valid-');
    final path = '${dir.path}/active.db';
    final db = await openDatabase(path);
    try {
      await createTaskSchema(db);
      await createPlanSnapshotSchema(db);
      await db.insert('tasks', {'id': 42, 'title': 'Keep', 'done': 0});
      final archive = await exportCombinedBackup(db);
      await db.close();
      final candidate = '${dir.path}/candidate.db';
      await stageCombinedBackup(archive, candidate);
      await inspectRestorePair(archive, path, candidate);
      final reader = await openDatabase(path);
      expect((await reader.query('tasks')).single['title'], 'Keep');
      await reader.close();
    } finally {
      if (db.isOpen) await db.close();
      await dir.delete(recursive: true);
    }
  });

}

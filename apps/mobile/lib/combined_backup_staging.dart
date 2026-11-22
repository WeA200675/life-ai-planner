import 'dart:io';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'combined_backup.dart';
import 'local_task_schema.dart';
import 'plan_snapshot_store.dart';
import 'task_backup.dart';
import 'plan_history_restore.dart';

/// Builds an isolated restore candidate. Never opens, replaces or renames the
/// active application database. The caller must choose a private new path.
/// A staged database is NOT automatically activated.
Future<({int tasks, int snapshots})> stageCombinedBackup(
    String archive, String candidatePath, {
    DatabaseFactory? factory,
  }) async {
  // Reject malformed data before creating any file.
  validateCombinedBackup(archive);
  if (candidatePath.trim().isEmpty ||
      !candidatePath.endsWith('.db')) {
    throw ArgumentError.value(candidatePath, 'candidatePath',
        'A new .db path is required');
  }
  final file = File(candidatePath);
  if (await _stagingFilesExist(candidatePath)) {
    throw StateError('Staging destination or SQLite sidecar already exists');
  }
  // Do not create parent directories or alter any pre-existing destination.
  if (!await file.parent.exists()) {
    throw StateError('Staging parent directory does not exist');
  }
  Database? db;
  var created = false;
  try {
    // SQLite may create the destination on open. Check again immediately
    // before open; concurrent external writers remain outside this API's
    // guarantees, so use a private app-controlled directory.
    if (await _stagingFilesExist(candidatePath)) {
      throw StateError('Staging destination or SQLite sidecar already exists');
    }
    created = true;
    db = await (factory ?? databaseFactory).openDatabase(candidatePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (database, _) async {
            await createTaskSchema(database);
            await createPlanSnapshotSchema(database);
          },
        ));
    final result = await restoreCombinedIntoEmptyDatabase(db, archive);
    await verifyStagedDatabase(db);
    await verifyStagedArchive(db, archive);
    // A candidate must not depend on uncheckpointed WAL pages when it is
    // eventually moved or reopened. Never attempt this on the active DB.
    await checkpointStagedDatabase(db);
    return result;
  } catch (_) {
    // Only delete a destination created by this attempt, never a file that
    // existed before the call.
    if (created) {
      await db?.close();
      db = null;
      for (final suffix in ['', '-wal', '-shm', '-journal']) {
        final candidate = File('$candidatePath$suffix');
        if (await candidate.exists()) await candidate.delete();
      }
    }
    rethrow;
  } finally {
    await db?.close();
  }
}

/// Independent post-import verification. SQLite integrity_check does not
/// detect orphaned foreign keys, so both checks are mandatory before a
/// staged database can ever be considered for activation.
Future<void> verifyStagedDatabase(Database db) async {
  final integrity = await db.rawQuery('PRAGMA integrity_check');
  if (integrity.length != 1 || integrity.single.values.single != 'ok') {
    throw StateError('Staged SQLite integrity check failed');
  }
  final foreignKeys = await db.rawQuery('PRAGMA foreign_key_check');
  if (foreignKeys.isNotEmpty) {
    throw StateError('Staged SQLite foreign key check failed');
  }
}

/// Compare restored content to the validated archive, not just SQLite's
/// structural checks. Catches missing, changed or extra rows before activation.
Future<void> verifyStagedArchive(Database db, String archive) async {
  validateCombinedBackup(archive);
  final expected = jsonDecode(archive) as Map<String, dynamic>;
  final actual = jsonDecode(await exportCombinedBackup(db))
      as Map<String, dynamic>;
  final expectedTasks = decodeTaskBackup(jsonEncode(expected['tasks']));
  final actualTasks = decodeTaskBackup(jsonEncode(actual['tasks']));
  final expectedHistory =
      decodePlanHistoryBackup(jsonEncode(expected['plan_history']));
  final actualHistory =
      decodePlanHistoryBackup(jsonEncode(actual['plan_history']));
  if (jsonEncode(expectedTasks.tasks) != jsonEncode(actualTasks.tasks) ||
      jsonEncode(expectedHistory.snapshots) !=
          jsonEncode(actualHistory.snapshots) ||
      jsonEncode(expectedHistory.blocks) !=
          jsonEncode(actualHistory.blocks)) {
    throw StateError('Staged content does not match the backup');
  }
}

/// Flush staged WAL pages into the main SQLite file before handing the
/// candidate to any future activation process. A busy checkpoint is fatal:
/// copying only the .db file while a WAL is pending would lose data.
Future<void> checkpointStagedDatabase(Database db) async {
  final mode = await db.rawQuery('PRAGMA journal_mode');
  if (mode.length != 1) {
    throw StateError('Cannot determine staged SQLite journal mode');
  }
  final journal = mode.single.values.single.toString().toLowerCase();
  if (journal != 'wal') return; // DELETE/TRUNCATE journals are not WAL.
  final rows = await db.rawQuery('PRAGMA wal_checkpoint(TRUNCATE)');
  if (rows.length != 1) {
    throw StateError('Staged WAL checkpoint returned no result');
  }
  final result = rows.single;
  final busy = result['busy'];
  final log = result['log'];
  final checkpointed = result['checkpointed'];
  if (busy != 0 || log is! int || checkpointed is! int ||
      !((log == -1 && checkpointed == -1) ||
          (log >= 0 && checkpointed >= 0 && log == checkpointed))) {
    throw StateError('Staged WAL checkpoint incomplete');
  }
}

/// SQLite may leave journal/WAL/SHM files even if the main database is absent.
/// Never stage over an existing sidecar: it might belong to an interrupted
/// operation and must not be silently destroyed.
Future<bool> _stagingFilesExist(String path) async {
  for (final suffix in ['', '-wal', '-shm', '-journal']) {
    if (await File('$path$suffix').exists()) return true;
  }
  return false;
}

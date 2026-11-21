import 'dart:io';

import 'package:sqflite/sqflite.dart';

import 'combined_backup.dart';
import 'local_task_schema.dart';
import 'plan_snapshot_store.dart';

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
  if (await file.exists()) {
    throw StateError('Staging destination already exists');
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
    if (await file.exists()) {
      throw StateError('Staging destination already exists');
    }
    db = await (factory ?? databaseFactory).openDatabase(candidatePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (database, _) async {
            await createTaskSchema(database);
            await createPlanSnapshotSchema(database);
          },
        ));
    created = true;
    final result = await restoreCombinedIntoEmptyDatabase(db, archive);
    final check = await db.rawQuery('PRAGMA integrity_check');
    if (check.length != 1 || check.single.values.single != 'ok') {
      throw StateError('Staged SQLite integrity check failed');
    }
    return result;
  } catch (_) {
    // Only delete a destination created by this attempt, never a file that
    // existed before the call.
    if (created) {
      await db?.close();
      db = null;
      if (await file.exists()) await file.delete();
    }
    rethrow;
  } finally {
    await db?.close();
  }
}

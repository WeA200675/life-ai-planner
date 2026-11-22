import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'offline_day_planner.dart';

/// Plan history is separate from task rows: accepting a plan never silently
/// modifies, deletes or completes tasks. Undo restores the previous snapshot.
Future<void> createPlanSnapshotSchema(DatabaseExecutor db) async {
  await db.execute('CREATE TABLE IF NOT EXISTS plan_snapshots ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'created_utc_ms INTEGER NOT NULL, '
      'window_start_utc_ms INTEGER NOT NULL, '
      'window_end_utc_ms INTEGER NOT NULL, '
      'budget_minutes INTEGER NOT NULL, '
      'reserved_minutes INTEGER NOT NULL)');
  await db.execute('CREATE TABLE IF NOT EXISTS plan_snapshot_blocks ('
      'snapshot_id INTEGER NOT NULL, '
      'position INTEGER NOT NULL, '
      'task_id TEXT NOT NULL, '
      'start_utc_ms INTEGER NOT NULL, '
      'end_utc_ms INTEGER NOT NULL, '
      'PRIMARY KEY(snapshot_id, position), '
      'FOREIGN KEY(snapshot_id) REFERENCES plan_snapshots(id) ON DELETE CASCADE)');
  await db.execute('CREATE INDEX IF NOT EXISTS idx_snapshot_blocks_snapshot '
      'ON plan_snapshot_blocks(snapshot_id)');
}

class SavedPlan {
  const SavedPlan(this.id, this.blocks, this.createdUtcMs);
  final int id;
  final List<DayBlock> blocks;
  final int createdUtcMs;
}

/// Canonical fingerprint of task rows. Ordering and map insertion order do not
/// affect the result, but every persisted field does.
String taskRowsFingerprint(List<Map<String, Object?>> rows) {
  final canonical = rows.map((row) {
    final sortedKeys = row.keys.toList()..sort();
    return {for (final key in sortedKeys) key: row[key]};
  }).toList()
    ..sort((a, b) => (a['id'] as int).compareTo(b['id'] as int));
  return jsonEncode(canonical);
}

class PlanSnapshotStore {
  const PlanSnapshotStore(this.db);
  final Database db;

  /// Atomic, append-only acceptance. No task table is ever changed.
  Future<int> accept(DayPlan plan, DateTime start, DateTime end, {
    List<Map<String, Object?>>? expectedTasks,
  }) async {
    if (!start.isBefore(end)) throw ArgumentError('Invalid window');
    if (plan.capacityMinutes < 0 || plan.budgetMinutes < 0 ||
        plan.reservedMinutes < 0 ||
        plan.budgetMinutes > plan.capacityMinutes ||
        plan.reservedMinutes > plan.capacityMinutes) {
      throw ArgumentError('Invalid plan capacity');
    }
    // A persisted snapshot must be internally coherent even when its caller
    // bypasses the planner. Reject contradictory or duplicate deferred IDs.
    final deferredIds = <String>{};
    for (final id in plan.deferred) {
      if (id.trim().isEmpty || id != id.trim() || !deferredIds.add(id)) {
        throw ArgumentError('Invalid or duplicate deferred task id');
      }
    }
    final ordered = [...plan.blocks]..sort((a, b) =>
        a.start.compareTo(b.start));
    final ids = <String>{};
    for (var i = 0; i < ordered.length; i++) {
      final block = ordered[i];
      if (block.id.trim().isEmpty || block.id != block.id.trim() ||
          deferredIds.contains(block.id) || !ids.add(block.id) ||
          (i > 0 && ordered[i - 1].end.isAfter(block.start))) {
        throw ArgumentError('Duplicate or overlapping plan blocks');
      }
    }
    for (final block in plan.blocks) {
      if (!block.start.isBefore(block.end) ||
          block.start.isBefore(start) || block.end.isAfter(end)) {
        throw ArgumentError('Invalid plan block');
      }
    }
    return db.transaction((txn) async {
      if (expectedTasks != null) {
        final current = await txn.query('tasks');
        if (taskRowsFingerprint(current) != taskRowsFingerprint(expectedTasks)) {
          throw StateError('Tasks changed since plan preview');
        }
      }
      final id = await txn.insert('plan_snapshots', {
        'created_utc_ms': DateTime.now().toUtc().millisecondsSinceEpoch,
        'window_start_utc_ms': start.toUtc().millisecondsSinceEpoch,
        'window_end_utc_ms': end.toUtc().millisecondsSinceEpoch,
        'budget_minutes': plan.budgetMinutes,
        'reserved_minutes': plan.reservedMinutes,
      });
      final batch = txn.batch();
      for (var i = 0; i < plan.blocks.length; i++) {
        final block = plan.blocks[i];
        batch.insert('plan_snapshot_blocks', {
          'snapshot_id': id, 'position': i, 'task_id': block.id,
          'start_utc_ms': block.start.toUtc().millisecondsSinceEpoch,
          'end_utc_ms': block.end.toUtc().millisecondsSinceEpoch,
        });
      }
      await batch.commit(noResult: true);
      return id;
    });
  }

  Future<SavedPlan?> latest() async {
    final headers = await db.query('plan_snapshots',
        columns: ['id', 'created_utc_ms'], orderBy: 'id DESC', limit: 1);
    if (headers.isEmpty) return null;
    final id = headers.single['id'] as int;
    final rows = await db.query('plan_snapshot_blocks',
        where: 'snapshot_id = ?', whereArgs: [id], orderBy: 'position ASC');
    return SavedPlan(id, List.unmodifiable(rows.map((row) => DayBlock(
      row['task_id'] as String,
      DateTime.fromMillisecondsSinceEpoch(row['start_utc_ms'] as int, isUtc: true),
      DateTime.fromMillisecondsSinceEpoch(row['end_utc_ms'] as int, isUtc: true),
    ))), headers.single['created_utc_ms'] as int);
  }

  /// Paginated history. Bounded queries avoid loading every old plan into RAM.
  /// Snapshot blocks are loaded only when a particular plan is opened.
  Future<List<SavedPlan>> history({int limit = 30, int offset = 0}) async {
    if (limit < 1 || limit > 100 || offset < 0) {
      throw ArgumentError('History pagination out of range');
    }
    final headers = await db.query('plan_snapshots',
        columns: ['id', 'created_utc_ms'],
        orderBy: 'id DESC', limit: limit, offset: offset);
    return List.unmodifiable(headers.map((row) => SavedPlan(
        row['id'] as int, const [], row['created_utc_ms'] as int)));
  }

  /// Stable cursor pagination: new plans cannot shift older pages.
  Future<List<SavedPlan>> historyBefore(int beforeId, {int limit = 30}) async {
    if (beforeId <= 0 || limit < 1 || limit > 100) {
      throw ArgumentError('Invalid history cursor or page size');
    }
    final headers = await db.query('plan_snapshots',
        columns: ['id', 'created_utc_ms'],
        where: 'id < ?', whereArgs: [beforeId],
        orderBy: 'id DESC', limit: limit);
    return List.unmodifiable(headers.map((row) => SavedPlan(
        row['id'] as int, const [], row['created_utc_ms'] as int)));
  }

  /// Read one historical version without modifying the active plan.
  Future<SavedPlan?> byId(int id) async {
    if (id <= 0) throw ArgumentError.value(id, 'id');
    final headers = await db.query('plan_snapshots',
        columns: ['id', 'created_utc_ms'],
        where: 'id = ?', whereArgs: [id], limit: 1);
    if (headers.isEmpty) return null;
    final rows = await db.query('plan_snapshot_blocks',
        where: 'snapshot_id = ?', whereArgs: [id], orderBy: 'position ASC');
    return SavedPlan(id, List.unmodifiable(rows.map((row) => DayBlock(
      row['task_id'] as String,
      DateTime.fromMillisecondsSinceEpoch(row['start_utc_ms'] as int, isUtc: true),
      DateTime.fromMillisecondsSinceEpoch(row['end_utc_ms'] as int, isUtc: true),
    ))), headers.single['created_utc_ms'] as int);
  }

  /// Undo only the expected newest version; stale confirmations cannot erase
  /// a newer plan accepted by another UI action.
  Future<bool> undoLatest(int expectedId) async {
    if (expectedId <= 0) throw ArgumentError.value(expectedId, 'expectedId');
    return db.transaction((txn) async {
      final rows = await txn.query('plan_snapshots',
          columns: ['id'], orderBy: 'id DESC', limit: 1);
      if (rows.isEmpty || rows.single['id'] != expectedId) return false;
      await txn.delete('plan_snapshot_blocks',
          where: 'snapshot_id = ?', whereArgs: [expectedId]);
      return await txn.delete('plan_snapshots',
          where: 'id = ?', whereArgs: [expectedId]) == 1;
    });
  }
}

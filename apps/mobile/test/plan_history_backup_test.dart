import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/offline_day_planner.dart';
import 'package:life_ai_planner/plan_history_backup.dart';
import 'package:life_ai_planner/plan_snapshot_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('exports all historical plans and blocks in stable order', () async {
    final db = await openDatabase(inMemoryDatabasePath);
    try {
      await createPlanSnapshotSchema(db);
      final store = PlanSnapshotStore(db);
      final start = DateTime.utc(2026, 11, 21, 8);
      final end = start.add(const Duration(hours: 8));
      for (final id in ['a', 'b']) {
        await store.accept(DayPlan([
          DayBlock(id, start, start.add(const Duration(minutes: 30))),
        ], const [], const [], 480, 336, 450), start, end);
      }
      final backup = await exportPlanHistoryBackup(db);
      expect(backup, await exportPlanHistoryBackup(db));
      final data = jsonDecode(backup) as Map<String, dynamic>;
      expect(data['format'], 'life-ai-planner-plan-history');
      expect(data['schema_version'], 1);
      expect(data['snapshots'], hasLength(2));
      expect(data['blocks'], hasLength(2));
      expect((data['blocks'] as List).first['task_id'], 'a');
      expect((data['blocks'] as List).last['task_id'], 'b');
      expect(await store.history(), hasLength(2));
    } finally {
      await db.close();
    }
  });

  test('rejects truncated history and corrupted orphan blocks', () async {
    final db = await openDatabase(inMemoryDatabasePath);
    try {
      await createPlanSnapshotSchema(db);
      final start = DateTime.utc(2026, 11, 21, 8);
      final end = start.add(const Duration(hours: 8));
      final store = PlanSnapshotStore(db);
      final plan = DayPlan([
        DayBlock('1', start, start.add(const Duration(minutes: 30))),
      ], const [], const [], 480, 336, 450);
      await store.accept(plan, start, end);
      await store.accept(plan, start, end);
      await expectLater(exportPlanHistoryBackup(db, maxSnapshots: 1),
          throwsFormatException);
      await db.insert('plan_snapshot_blocks', {
        'snapshot_id': 9999, 'position': 0, 'task_id': 'orphan',
        'start_utc_ms': start.millisecondsSinceEpoch,
        'end_utc_ms': start.add(const Duration(minutes: 10))
            .millisecondsSinceEpoch,
      });
      await expectLater(exportPlanHistoryBackup(db), throwsFormatException);
    } finally {
      await db.close();
    }
  });

  test('rejects too-small output limit without modifying snapshots', () async {
    final db = await openDatabase(inMemoryDatabasePath);
    try {
      await createPlanSnapshotSchema(db);
      await expectLater(exportPlanHistoryBackup(db, maxBytes: 5),
          throwsFormatException);
      expect(await db.query('plan_snapshots'), isEmpty);
    } finally {
      await db.close();
    }
  });
}

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/plan_history_backup.dart';
import 'package:life_ai_planner/plan_history_restore.dart';
import 'package:life_ai_planner/plan_snapshot_store.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('round-trip preserves IDs and blocks in an empty history database', () async {
    final source = await openDatabase(inMemoryDatabasePath);
    final target = await openDatabase(inMemoryDatabasePath);
    try {
      await createPlanSnapshotSchema(source);
      await createPlanSnapshotSchema(target);
      await source.insert('plan_snapshots', {
        'id': 8,
        'created_utc_ms': 1000,
        'window_start_utc_ms': 2000,
        'window_end_utc_ms': 5000,
        'budget_minutes': 20,
        'reserved_minutes': 10,
      });
      await source.insert('plan_snapshot_blocks', {
        'snapshot_id': 8,
        'position': 0,
        'task_id': 'synthetic',
        'start_utc_ms': 2500,
        'end_utc_ms': 3000,
      });
      final backup = await exportPlanHistoryBackup(source);
      final archive = decodePlanHistoryBackup(backup);
      expect(await restorePlanHistoryIntoEmptyDatabase(target, archive), 1);
      expect(await exportPlanHistoryBackup(target), backup);
      await expectLater(restorePlanHistoryIntoEmptyDatabase(target, archive),
          throwsStateError);
      expect(await exportPlanHistoryBackup(target), backup);
    } finally {
      await source.close();
      await target.close();
    }
  });

  test('malformed, orphaned, duplicate and overlapping blocks rejected', () async {
    final base = {
      'format': 'life-ai-planner-plan-history',
      'schema_version': 1,
      'snapshots': [
        {
          'id': 1, 'created_utc_ms': 1000,
          'window_start_utc_ms': 2000, 'window_end_utc_ms': 6000,
          'budget_minutes': 20, 'reserved_minutes': 10,
        }
      ],
      'blocks': [
        {
          'snapshot_id': 1, 'position': 0, 'task_id': 'a',
          'start_utc_ms': 2500, 'end_utc_ms': 3000,
        }
      ],
    };
    expect(decodePlanHistoryBackup(jsonEncode(base)).blocks, hasLength(1));
    for (final bad in [
      {...base, 'schema_version': 2},
      {...base, 'extra': 1},
      {...base, 'blocks': [
        {...(base['blocks'] as List).first as Map, 'snapshot_id': 99}
      ]},
      {...base, 'blocks': [
        ...(base['blocks'] as List),
        {
          'snapshot_id': 1, 'position': 1, 'task_id': 'b',
          'start_utc_ms': 2900, 'end_utc_ms': 4000,
        },
      ]},
      {...base, 'snapshots': [
        ...(base['snapshots'] as List),
        (base['snapshots'] as List).first,
      ]},
    ]) {
      expect(() => decodePlanHistoryBackup(jsonEncode(bad)),
          throwsFormatException);
    }
  });

  test('untrusted mutated archive is rejected before touching destination', () async {
    final db = await openDatabase(inMemoryDatabasePath);
    try {
      await createPlanSnapshotSchema(db);
      final bad = PlanHistoryArchive([
        {
          'id': 1, 'created_utc_ms': 1000,
          'window_start_utc_ms': 2000, 'window_end_utc_ms': 3000,
          'budget_minutes': -1, 'reserved_minutes': 0,
        }
      ], const []);
      await expectLater(restorePlanHistoryIntoEmptyDatabase(db, bad),
          throwsFormatException);
      expect(await db.query('plan_snapshots'), isEmpty);
    } finally {
      await db.close();
    }
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/restore_journal.dart';
import 'package:life_ai_planner/restore_journal_store.dart';

void main() {
  const store = RestoreJournalStore();
  const journal = RestoreJournal(
    operationId: 'synthetic_operation_002',
    phase: RestorePhase.prepared,
    activePath: '/isolated/active.db',
    candidatePath: '/isolated/candidate.db',
    backupPath: '/isolated/backup.db',
  );

  test('exclusive marker survives reopening and refuses overwrite', () async {
    final dir = await Directory.systemTemp.createTemp('journal-test-');
    try {
      final marker = File('${dir.path}/restore.marker');
      await store.create(marker, journal);
      expect((await store.read(marker)).operationId, journal.operationId);
      await expectLater(store.create(marker, journal), throwsA(isA<Object>()));
      expect((await store.read(marker)).phase, RestorePhase.prepared);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('partial marker is rejected without deleting it', () async {
    final dir = await Directory.systemTemp.createTemp('journal-test-');
    try {
      final marker = File('${dir.path}/restore.marker');
      await marker.writeAsString('{"version":');
      await expectLater(store.read(marker), throwsFormatException);
      expect(await marker.exists(), isTrue);
      await expectLater(store.create(marker, journal), throwsStateError);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('invalid journal does not create a marker', () async {
    final dir = await Directory.systemTemp.createTemp('journal-test-');
    try {
      final marker = File('${dir.path}/restore.marker');
      const invalid = RestoreJournal(
        operationId: 'bad',
        phase: RestorePhase.prepared,
        activePath: '/a.db',
        candidatePath: '/b.db',
        backupPath: '/c.db',
      );
      await expectLater(store.create(marker, invalid), throwsFormatException);
      expect(await marker.exists(), isFalse);
    } finally {
      await dir.delete(recursive: true);
    }
  });
}

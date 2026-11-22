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
  test('oversized marker fails closed and remains untouched', () async {
    final dir = await Directory.systemTemp.createTemp('journal-limit-test-');
    try {
      final marker = File('${dir.path}/restore.marker');
      await marker.writeAsString('x' * (RestoreJournalStore.maxMarkerBytes + 1));
      await expectLater(store.read(marker), throwsFormatException);
      expect(await marker.length(), RestoreJournalStore.maxMarkerBytes + 1);
      await expectLater(store.create(marker, journal), throwsStateError);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('oversized valid journal is rejected before creating a file', () async {
    final dir = await Directory.systemTemp.createTemp('journal-write-limit-');
    try {
      final marker = File('${dir.path}/restore.marker');
      final oversized = RestoreJournal(
        operationId: 'synthetic_operation_oversized',
        phase: RestorePhase.prepared,
        activePath: '/isolated/${'a' * 17000}.db',
        candidatePath: '/isolated/candidate.db',
        backupPath: '/isolated/backup.db',
      );
      await expectLater(store.create(marker, oversized), throwsFormatException);
      expect(await marker.exists(), isFalse);
      await store.create(marker, journal);
      expect((await store.read(marker)).operationId, journal.operationId);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('symlinked ancestor refuses marker read and creation', () async {
    if (Platform.isWindows) return;
    final root = await Directory.systemTemp.createTemp('journal-link-test-');
    try {
      final real = Directory('${root.path}/real');
      await real.create();
      final link = Link('${root.path}/alias');
      await link.create(real.path);
      final marker = File('${link.path}/restore.marker');
      await expectLater(store.create(marker, journal), throwsStateError);
      expect(await File('${real.path}/restore.marker').exists(), isFalse);
      final original = File('${real.path}/restore.marker');
      await store.create(original, journal);
      await expectLater(store.read(marker), throwsStateError);
      expect((await store.read(original)).phase, RestorePhase.prepared);
    } finally {
      await root.delete(recursive: true);
    }
  });

  test('symlinked marker refuses read and cannot replace target', () async {
    if (Platform.isWindows) return;
    final root = await Directory.systemTemp.createTemp('journal-file-link-');
    try {
      final target = File('${root.path}/target.marker');
      await store.create(target, journal);
      final link = Link('${root.path}/alias.marker');
      await link.create(target.path);
      await expectLater(store.read(File(link.path)), throwsStateError);
      await expectLater(store.create(File(link.path), journal), throwsStateError);
      expect((await store.read(target)).operationId, journal.operationId);
    } finally {
      await root.delete(recursive: true);
    }
  });


  test('concurrent creators never replace the winning marker', () async {
    final dir = await Directory.systemTemp.createTemp('journal-race-test-');
    try {
      final marker = File('${dir.path}/restore.marker');
      final attempts = await Future.wait(List.generate(12, (_) async {
        try {
          await store.create(marker, journal);
          return true;
        } catch (_) {
          return false;
        }
      }));
      expect(attempts.where((success) => success).length, 1);
      expect((await store.read(marker)).operationId, journal.operationId);
      expect(await marker.length(), greaterThan(0));
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('empty and truncated markers fail closed and remain on disk', () async {
    final dir = await Directory.systemTemp.createTemp('journal-crash-test-');
    try {
      for (final value in <String>['', '{', '{"version":']) {
        final marker = File('${dir.path}/restore.marker');
        await marker.writeAsString(value, flush: true);
        await expectLater(store.read(marker), throwsFormatException);
        expect(await marker.readAsString(), value);
        await expectLater(store.create(marker, journal), throwsStateError);
        await marker.delete();
      }
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('distinct restore operations cannot overwrite an existing marker',
      () async {
    final dir = await Directory.systemTemp.createTemp('journal-identity-test-');
    try {
      final marker = File('${dir.path}/restore.marker');
      await store.create(marker, journal);
      const second = RestoreJournal(
        operationId: 'synthetic_operation_003',
        phase: RestorePhase.prepared,
        activePath: '/isolated/active.db',
        candidatePath: '/isolated/candidate.db',
        backupPath: '/isolated/backup.db',
      );
      await expectLater(store.create(marker, second), throwsStateError);
      expect((await store.read(marker)).operationId, journal.operationId);
    } finally {
      await dir.delete(recursive: true);
    }
  });

}

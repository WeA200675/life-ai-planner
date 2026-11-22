import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/restore_journal.dart';

void main() {
  const journal = RestoreJournal(
    operationId: 'synthetic_operation_001',
    phase: RestorePhase.prepared,
    activePath: '/private/active.db',
    candidatePath: '/private/candidate.db',
    backupPath: '/private/original.db',
  );

  test('roundtrip preserves strict journal fields', () {
    final decoded = RestoreJournal.decode(journal.encode());
    expect(decoded.operationId, journal.operationId);
    expect(decoded.phase, RestorePhase.prepared);
    expect(decoded.activePath, journal.activePath);
    expect(decoded.candidatePath, journal.candidatePath);
    expect(decoded.backupPath, journal.backupPath);
  });

  test('only consecutive forward transitions are allowed', () {
    expect(() => journal.advance(RestorePhase.verified), throwsStateError);
    expect(() => journal.advance(RestorePhase.prepared), throwsStateError);
    final preserved = journal.advance(RestorePhase.originalPreserved);
    final installed = preserved.advance(RestorePhase.candidateInstalled);
    expect(installed.advance(RestorePhase.verified).phase,
        RestorePhase.verified);
    expect(() => installed.advance(RestorePhase.prepared), throwsStateError);
  });

  test('rejects malformed and future journals without fallback', () {
    expect(() => RestoreJournal.decode('{'), throwsFormatException);
    final valid = journal.encode();
    expect(() => RestoreJournal.decode(valid.replaceFirst(
        '"version":1', '"version":2')), throwsFormatException);
    expect(() => RestoreJournal.decode(valid.replaceFirst(
        '"prepared"', '"unknown"')), throwsFormatException);
    expect(() => RestoreJournal.decode(valid.replaceFirst(
        '"prepared"', 'null')), throwsFormatException);
    expect(() => RestoreJournal.decode(valid.replaceFirst(
        '"prepared"', '"verified"').replaceFirst(
        '"version":1', '"version":true')), throwsFormatException);
  });

  test('rejects path collisions, unknown keys and invalid operation IDs', () {
    final valid = journal.encode();
    expect(() => RestoreJournal.decode(valid.replaceFirst(
        '/private/candidate.db', '/private/active.db')), throwsFormatException);
    expect(() => RestoreJournal.decode(valid.replaceFirst(
        '/private/candidate.db', ' ')), throwsFormatException);
    expect(() => RestoreJournal.decode(valid.replaceFirst(
        'synthetic_operation_001', 'short')), throwsFormatException);
    expect(() => RestoreJournal.decode(valid.replaceFirst(
        '"version":1', '"version":1,"unexpected":true')), throwsFormatException);
  });
}

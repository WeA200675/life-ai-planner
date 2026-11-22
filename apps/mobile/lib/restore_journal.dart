import 'dart:convert';

/// A strictly validated, non-executable recovery journal description.
///
/// This codec does not write files or activate a database. A future recovery
/// executor must durably persist each phase *before* changing filesystem
/// state and must verify both SQLite files independently.
enum RestorePhase { prepared, originalPreserved, candidateInstalled, verified }

class RestoreJournal {
  const RestoreJournal({
    required this.operationId,
    required this.phase,
    required this.activePath,
    required this.candidatePath,
    required this.backupPath,
  });

  final String operationId;
  final RestorePhase phase;
  final String activePath;
  final String candidatePath;
  final String backupPath;

  static const int schemaVersion = 1;

  String encode() => jsonEncode({
        'version': schemaVersion,
        'operation_id': operationId,
        'phase': phase.name,
        'active_path': activePath,
        'candidate_path': candidatePath,
        'backup_path': backupPath,
      });

  static RestoreJournal decode(String raw) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      throw const FormatException('Invalid restore journal JSON');
    }
    if (decoded is! Map<String, dynamic> ||
        decoded.length != 6 ||
        decoded.keys.toSet().difference({
          'version', 'operation_id', 'phase', 'active_path',
          'candidate_path', 'backup_path',
        }).isNotEmpty ||
        decoded['version'] != schemaVersion ||
        decoded['version'] is! int) {
      throw const FormatException('Unsupported restore journal schema');
    }
    final id = decoded['operation_id'];
    final phaseName = decoded['phase'];
    final active = decoded['active_path'];
    final candidate = decoded['candidate_path'];
    final backup = decoded['backup_path'];
    if (id is! String ||
        !RegExp(r'^[a-zA-Z0-9_-]{16,80}$').hasMatch(id) ||
        phaseName is! String ||
        active is! String ||
        candidate is! String ||
        backup is! String) {
      throw const FormatException('Invalid restore journal fields');
    }
    final phase = RestorePhase.values.where((p) => p.name == phaseName);
    if (phase.length != 1) {
      throw const FormatException('Unknown restore journal phase');
    }
    final paths = [active, candidate, backup];
    if (paths.any((p) => p.isEmpty || p.trim() != p || !p.endsWith('.db')) ||
        paths.toSet().length != 3) {
      throw const FormatException('Invalid or overlapping restore paths');
    }
    return RestoreJournal(
      operationId: id,
      phase: phase.single,
      activePath: active,
      candidatePath: candidate,
      backupPath: backup,
    );
  }

  /// Fail closed on skipped or reversed phases. The executor must never
  /// infer successful filesystem mutations merely from a journal phase.
  RestoreJournal advance(RestorePhase next) {
    if (next.index != phase.index + 1) {
      throw StateError('Restore journal phase transition rejected');
    }
    return RestoreJournal(
      operationId: operationId,
      phase: next,
      activePath: activePath,
      candidatePath: candidatePath,
      backupPath: backupPath,
    );
  }
}

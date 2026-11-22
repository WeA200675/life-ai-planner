import 'dart:convert';
import 'dart:io';

import 'restore_journal.dart';

/// Fail-closed, exclusive marker creation for an isolated restore operation.
///
/// A crash during writing may leave a partial marker. Such a marker must never
/// be interpreted as permission to activate a database: [read] rejects it.
/// The marker is intentionally never overwritten or automatically removed.
/// This is NOT a crash-durable swap protocol (directory fsync is unavailable).
class RestoreJournalStore {
  const RestoreJournalStore();

  // Recovery metadata is small; never load unbounded attacker-controlled files.
  static const int maxMarkerBytes = 16384;

  /// Reject symlinked marker paths and ancestors. This is a preflight only:
  /// callers must use a private directory inaccessible to other writers.
  Future<void> _checkMarkerPath(File marker) async {
    var current = marker.absolute.path;
    while (true) {
      if (await FileSystemEntity.type(current, followLinks: false) ==
          FileSystemEntityType.link) {
        throw StateError('Restore marker path contains a symbolic link');
      }
      final parent = File(current).parent.path;
      if (parent == current) break;
      current = parent;
    }
  }

  Future<void> create(File marker, RestoreJournal journal) async {
    await _checkMarkerPath(marker);
    final validated = RestoreJournal.decode(journal.encode());
    final encoded = validated.encode();
    if (utf8.encode(encoded).length > maxMarkerBytes) {
      throw const FormatException('Restore marker exceeds size limit');
    }
    if (await FileSystemEntity.type(marker.path, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw StateError('Restore marker already exists');
    }
    RandomAccessFile? handle;
    try {
      // Dart FileMode has no writeOnlyExclusive. File.create(exclusive: true)
      // performs the atomic no-clobber creation; only then open the new file.
      // A crash between these operations leaves an invalid marker, which
      // read() rejects. The private restore directory excludes hostile writers.
      await marker.create(exclusive: true);
      handle = await marker.open(mode: FileMode.writeOnly);
      await handle.writeString(encoded);
      await handle.flush();
    } finally {
      await handle?.close();
    }
  }

  Future<RestoreJournal> read(File marker) async {
    await _checkMarkerPath(marker);
    if (await FileSystemEntity.type(marker.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw StateError('Restore marker missing or not a regular file');
    }
    // Bound memory even when the file changes after the initial type check.
    final bytes = await marker.openRead(0, maxMarkerBytes + 1).expand((b) => b).toList();
    if (bytes.length > maxMarkerBytes) {
      throw const FormatException('Restore marker exceeds size limit');
    }
    return RestoreJournal.decode(utf8.decode(bytes));
  }
}

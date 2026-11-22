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

  Future<void> create(File marker, RestoreJournal journal) async {
    final validated = RestoreJournal.decode(journal.encode());
    if (await FileSystemEntity.type(marker.path, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw StateError('Restore marker already exists');
    }
    RandomAccessFile? handle;
    try {
      // Exclusive creation prevents replacing an existing regular file.
      handle = await marker.open(mode: FileMode.writeOnlyExclusive);
      await handle.writeString(validated.encode());
      await handle.flush();
    } finally {
      await handle?.close();
    }
  }

  Future<RestoreJournal> read(File marker) async {
    if (await FileSystemEntity.type(marker.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw StateError('Restore marker missing or not a regular file');
    }
    return RestoreJournal.decode(await marker.readAsString());
  }
}

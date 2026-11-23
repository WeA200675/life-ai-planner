import 'package:flutter_test/flutter_test.dart';
import 'package:life_ai_planner/sqlite_integrity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  final factory = databaseFactoryFfi;

  test('corrupt legacy relationships reject upgrade before DDL', () async {
    final path = inMemoryDatabasePath;
    final db = await factory.openDatabase(path,
        options: OpenDatabaseOptions(
          singleInstance: false,
          version: 1,
          onCreate: (db, _) async {
            await db.execute('CREATE TABLE parents (id INTEGER PRIMARY KEY)');
            await db.execute('CREATE TABLE children (parent_id INTEGER REFERENCES parents(id))');
            await db.execute('PRAGMA foreign_keys = OFF');
            await db.execute('INSERT INTO children(parent_id) VALUES (999)');
          },
        ));
    // Keep the same connection for the upgrade; SQLite in-memory paths do
    // not survive closing the connection.
    await expectLater(
      () async {
        await requireValidSqliteStructure(db);
        await requireValidForeignKeys(db);
        await db.execute('CREATE TABLE must_not_exist (id INTEGER)');
      },
      throwsStateError,
    );
    final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='must_not_exist'");
    expect(tables, isEmpty);
    await db.close();
  });
}

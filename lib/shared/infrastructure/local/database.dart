import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tcompro/shared/infrastructure/local/database_key_store.dart';
import 'package:tcompro/shared/infrastructure/local/tables/profiles_table.dart';
import 'package:tcompro/shared/infrastructure/local/dao/profile_dao.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Profiles], daos: [ProfileDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

/// Opens the encrypted application database.
///
/// Retrieves (or generates) the SQLCipher key from secure storage and opens
/// the database file with it. Must be called once at startup and the result
/// injected down the tree.
Future<AppDatabase> openAppDatabase(DatabaseKeyStore keyStore) async {
  final key = await keyStore.getOrCreateKey();
  return AppDatabase(_openEncryptedConnection(key));
}

LazyDatabase _openEncryptedConnection(String hexKey) {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'tcompro.db'));

    return NativeDatabase(
      file,
      setup: (db) {
        // The sqlite3 binary is the SQLite3MultipleCiphers build (see the
        // `hooks` section in pubspec.yaml). Select the SQLCipher-compatible
        // scheme, then unlock with the raw hex key before any other access.
        db.execute("PRAGMA cipher = 'sqlcipher';");
        db.execute('PRAGMA legacy = 4;');
        db.execute('PRAGMA key = "x\'$hexKey\'";');
      },
    );
  });
}

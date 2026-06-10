import 'package:drift/drift.dart';

/// Local mirror of a remote `profiles` row.
///
/// The generated data class is named `ProfileRow` to avoid colliding with the
/// domain [Profile] model.
@DataClassName('ProfileRow')
class Profiles extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text()();
  TextColumn get email => text()();
  TextColumn get avatarUrl => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';

/// Base for every local (on-device) data service.
///
/// A local service is a thin, domain-aware wrapper around a single Drift DAO.
/// It owns the mapping between Drift row/companion types and domain models so
/// that the rest of the app never sees `drift` types. Holding the DAO (rather
/// than the whole [AppDatabase]) keeps each service's surface narrow and its
/// dependencies explicit.
abstract class BaseLocalService<T extends DatabaseAccessor> {
  final T dao;

  const BaseLocalService(this.dao);
}

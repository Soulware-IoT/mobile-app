/// Raised by repositories when an operation is attempted with no connectivity.
///
/// Carries no message: the UI maps it to a localized string via
/// `localizedError`, so the wording follows the device language.
class NoConnectionException implements Exception {
  const NoConnectionException();

  @override
  String toString() => 'NoConnectionException';
}

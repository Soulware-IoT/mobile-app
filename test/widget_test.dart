// Placeholder test suite.
//
// The default counter smoke test was removed: this app has no counter, and
// MainApp now requires a live encrypted database + secure storage, which rely
// on platform channels not available in a plain `flutter test` run.
//
// TODO: add unit tests for the offline pieces that don't need a real DB —
// e.g. AuthRepositoryImpl session mapping (with fakes for AuthLocalService /
// NetworkChecker) and ProfileRepositoryImpl local-first fallback.

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('placeholder', () {
    expect(true, isTrue);
  });
}

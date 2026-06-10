import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the SQLCipher encryption key for the local database.
///
/// The key is generated once per installation and persisted in the
/// platform's secure storage (Keychain / Keystore). It is never derived
/// from user input, so the encrypted database remains readable across
/// sessions without prompting the user — the device's own secure storage
/// is the trust anchor.
class DatabaseKeyStore {
  final FlutterSecureStorage _storage;
  static const _keyName = 'db_encryption_key';
  static const _keyLengthBytes = 32; // 256-bit key

  const DatabaseKeyStore(this._storage);

  /// Returns the existing key, or generates and persists a new one on first run.
  ///
  /// The key is returned as a hex string so it can be handed to SQLCipher as a
  /// raw key (`PRAGMA key = "x'...'"`), skipping key-derivation entirely.
  Future<String> getOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null) return existing;

    final rng = Random.secure();
    final bytes = List<int>.generate(_keyLengthBytes, (_) => rng.nextInt(256));
    final hex = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    await _storage.write(key: _keyName, value: hex);
    return hex;
  }
}

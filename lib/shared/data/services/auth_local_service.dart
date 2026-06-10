import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthLocalService {
  final FlutterSecureStorage _secureStorage;
  static const _lastUserKey = 'last_authenticated_user_id';

  const AuthLocalService(this._secureStorage);

  Future<String?> getCachedUserId() async {
    return await _secureStorage.read(key: _lastUserKey);
  }

  Future<void> cacheUserId(String userId) async {
    await _secureStorage.write(key: _lastUserKey, value: userId);
  }

  Future<void> clearCachedUserId() async {
    await _secureStorage.delete(key: _lastUserKey);
  }
}

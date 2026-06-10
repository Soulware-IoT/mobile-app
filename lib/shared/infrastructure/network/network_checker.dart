import 'dart:io';

class NetworkChecker {
  final String supabaseUrl;
  final int optimalConnectionTimeSeconds = 4;

  const NetworkChecker(this.supabaseUrl);

  Future<bool> get isConnected async {
    try {
      final uri = Uri.tryParse(supabaseUrl);
      if (uri == null) return false;

      final host = uri.host;
      if (host.isEmpty) return false;

      final result = await InternetAddress.lookup(
        host,
      ).timeout(const Duration(seconds: 4));

      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

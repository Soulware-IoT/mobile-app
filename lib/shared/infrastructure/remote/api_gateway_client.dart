import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Raised when the api-gw returns a non-2xx response or is not reachable.
class ApiGatewayException implements Exception {
  final int statusCode;
  final String message;

  const ApiGatewayException(this.statusCode, this.message);

  @override
  String toString() => 'ApiGatewayException($statusCode): $message';
}

/// Thin HTTP wrapper around the NestJS api-gateway.
///
/// Every request carries the current Supabase access token as a Bearer header
/// so the gateway's `SupabaseAuthGuard` can authenticate it. The base URL comes
/// from `API_GATEWAY_URL`; while that value is empty (gateway not yet wired)
/// calls fail fast with an [ApiGatewayException] that the UI surfaces as an
/// error state instead of crashing.
class ApiGatewayClient {
  final String baseUrl;
  final SupabaseClient supabase;
  final http.Client _http;

  ApiGatewayClient({
    required this.baseUrl,
    required this.supabase,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  Map<String, String> _headers() {
    final token = supabase.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      // The gateway forwards Accept-Language to the backend, which localizes
      // its error messages from it. Derive it from the device locale (es/en).
      'Accept-Language': _acceptLanguage(),
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  String _acceptLanguage() {
    final code = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    return code == 'es' ? 'es' : 'en';
  }

  Uri _uri(String path, Map<String, dynamic>? query) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final uri = Uri.parse('$normalized$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
      queryParameters: query.map((k, v) => MapEntry(k, '$v')),
    );
  }

  Future<dynamic> getJson(String path, {Map<String, dynamic>? query}) async {
    if (baseUrl.isEmpty) {
      throw const ApiGatewayException(0, 'API_GATEWAY_URL no está configurada');
    }

    final response = await _http.get(_uri(path, query), headers: _headers());
    return _decode(response);
  }

  Future<dynamic> patchJson(String path, {Object? body}) async {
    if (baseUrl.isEmpty) {
      throw const ApiGatewayException(0, 'API_GATEWAY_URL no está configurada');
    }

    final response = await _http.patch(
      _uri(path, null),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> putJson(String path, {Object? body}) async {
    if (baseUrl.isEmpty) {
      throw const ApiGatewayException(0, 'API_GATEWAY_URL no está configurada');
    }

    final response = await _http.put(
      _uri(path, null),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> postJson(String path, {Object? body}) async {
    if (baseUrl.isEmpty) {
      throw const ApiGatewayException(0, 'API_GATEWAY_URL no está configurada');
    }

    final response = await _http.post(
      _uri(path, null),
      headers: _headers(),
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(response);
  }

  Future<dynamic> deleteJson(String path) async {
    if (baseUrl.isEmpty) {
      throw const ApiGatewayException(0, 'API_GATEWAY_URL no está configurada');
    }

    final response = await _http.delete(_uri(path, null), headers: _headers());
    return _decode(response);
  }

  dynamic _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiGatewayException(response.statusCode, _errorMessage(response.body));
    }

    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  /// Extracts the human-readable, server-localized `message` from an error body.
  /// Covers the backend's `ErrorResponse` and NestJS's `{message, error}` shape;
  /// falls back to the raw body when it isn't the expected JSON.
  String _errorMessage(String body) {
    if (body.isEmpty) return body;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        final message = decoded['message'];
        // NestJS validation errors can return message as a list of strings.
        if (message is List) return message.join(', ');
        return message.toString();
      }
    } catch (_) {
      // Not JSON — fall through to the raw body.
    }
    return body;
  }
}

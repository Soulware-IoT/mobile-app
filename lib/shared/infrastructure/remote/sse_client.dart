import 'dart:async';
import 'dart:convert';
import 'dart:ui' show PlatformDispatcher;

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'api_gateway_client.dart' show ApiGatewayException;

/// One parsed Server-Sent Event: the optional `event:` name and its JSON
/// `data:` payload. Events whose data isn't a JSON object (e.g. heartbeat
/// comments) never surface here — they're dropped during parsing.
class SseEvent {
  final String? event;
  final Map<String, dynamic> data;

  const SseEvent({this.event, required this.data});
}

/// Minimal SSE consumer for the api-gw's `text/event-stream` endpoints.
///
/// The native `EventSource` idea doesn't apply here (no way to attach the
/// Supabase Bearer token), so this mirrors the web app's fetch-based client:
/// a plain streamed GET whose body is parsed line by line.
///
/// Each [events] call is ONE connection attempt: it errors on a non-2xx
/// response and completes when the server drops. Reconnection/backoff is the
/// caller's job (the cubit), which also means every retry rebuilds headers
/// and naturally picks up a refreshed access token.
class SseClient {
  final String baseUrl;
  final SupabaseClient supabase;

  /// Injectable for tests; each connection gets a fresh client.
  final http.Client Function() clientFactory;

  SseClient({
    required this.baseUrl,
    required this.supabase,
    this.clientFactory = http.Client.new,
  });

  Stream<SseEvent> events(String path, {String? eventName}) {
    late StreamController<SseEvent> controller;
    http.Client? client;
    StreamSubscription<String>? lines;

    Future<void> connect() async {
      if (baseUrl.isEmpty) {
        throw const ApiGatewayException(
          0,
          'API_GATEWAY_URL no está configurada',
        );
      }

      final normalized = baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
      final token = supabase.auth.currentSession?.accessToken;

      final request = http.Request('GET', Uri.parse('$normalized$path'))
        ..headers.addAll({
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
          'Accept-Language': _acceptLanguage(),
          if (token != null) 'Authorization': 'Bearer $token',
        });

      // A dedicated client per connection: cancelling the stream must abort
      // the socket, and http.Client.close() is the only way to do that.
      final httpClient = clientFactory();
      client = httpClient;
      final response = await httpClient.send(request);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final body = await response.stream.bytesToString();
        throw ApiGatewayException(response.statusCode, _errorMessage(body));
      }

      String? currentEvent;
      final dataLines = <String>[];

      void dispatch() {
        if (dataLines.isEmpty) {
          currentEvent = null;
          return;
        }
        final raw = dataLines.join('\n');
        final name = currentEvent;
        dataLines.clear();
        currentEvent = null;

        if (eventName != null && name != eventName) return;

        final dynamic decoded;
        try {
          decoded = jsonDecode(raw);
        } catch (_) {
          return; // Heartbeats / non-JSON payloads are silently ignored.
        }
        if (decoded is! Map<String, dynamic>) return;
        controller.add(SseEvent(event: name, data: decoded));
      }

      lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
            (line) {
              if (line.isEmpty) {
                dispatch();
              } else if (line.startsWith(':')) {
                // SSE comment — the gateway's 15s keep-alive heartbeats.
              } else if (line.startsWith('event:')) {
                currentEvent = line.substring(6).trim();
              } else if (line.startsWith('data:')) {
                dataLines.add(
                  line.substring(5, 6) == ' '
                      ? line.substring(6)
                      : line.substring(5),
                );
              }
              // `id:` / `retry:` fields are irrelevant here — ignored.
            },
            onError: controller.addError,
            onDone: () {
              dispatch(); // Flush a trailing event without a final blank line.
              controller.close();
            },
            cancelOnError: false,
          );
    }

    controller = StreamController<SseEvent>(
      onListen: () {
        connect().catchError((Object e, StackTrace s) {
          if (!controller.isClosed) {
            controller.addError(e, s);
            controller.close();
          }
        });
      },
      onCancel: () async {
        await lines?.cancel();
        client?.close();
      },
    );

    return controller.stream;
  }

  String _acceptLanguage() {
    final code = PlatformDispatcher.instance.locale.languageCode.toLowerCase();
    return code == 'es' ? 'es' : 'en';
  }

  /// Same unwrapping as ApiGatewayClient: prefer the server-localized
  /// `message` field, fall back to the raw body.
  String _errorMessage(String body) {
    if (body.isEmpty) return body;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] != null) {
        final message = decoded['message'];
        if (message is List) return message.join(', ');
        return message.toString();
      }
    } catch (_) {
      // Not JSON — fall through to the raw body.
    }
    return body;
  }
}

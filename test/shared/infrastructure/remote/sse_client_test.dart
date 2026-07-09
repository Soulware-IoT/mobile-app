import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cocina360/shared/infrastructure/remote/api_gateway_client.dart';
import 'package:cocina360/shared/infrastructure/remote/sse_client.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockSession extends Mock implements Session {}

/// Fake http.Client whose send() answers with a streamed body under our
/// control, and records whether close() aborted the connection.
class FakeStreamingClient extends http.BaseClient {
  final int statusCode;
  final StreamController<List<int>> body = StreamController<List<int>>();
  http.BaseRequest? lastRequest;
  bool closed = false;

  FakeStreamingClient({this.statusCode = 200});

  void addLines(String text) => body.add(utf8.encode(text));

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    return http.StreamedResponse(body.stream, statusCode);
  }

  @override
  void close() {
    closed = true;
    if (!body.isClosed) body.close();
    super.close();
  }
}

void main() {
  late MockSupabaseClient supabase;
  late MockGoTrueClient auth;
  late FakeStreamingClient fake;
  late SseClient client;

  SseClient buildClient({String baseUrl = 'https://gw.test'}) => SseClient(
    baseUrl: baseUrl,
    supabase: supabase,
    clientFactory: () => fake,
  );

  setUp(() {
    supabase = MockSupabaseClient();
    auth = MockGoTrueClient();
    fake = FakeStreamingClient();

    when(() => supabase.auth).thenReturn(auth);
    when(() => auth.currentSession).thenReturn(null);

    client = buildClient();
  });

  test('parsea eventos con nombre y data JSON, y envía headers SSE', () async {
    final events = client.events('/orgs/1/readings/stream');
    final collected = <SseEvent>[];
    final done = events.listen(collected.add).asFuture<void>().catchError((_) {});

    fake.addLines('event: reading\ndata: {"a":1}\n\n');
    await Future<void>.delayed(Duration.zero);
    await fake.body.close();
    await done;

    expect(collected, hasLength(1));
    expect(collected.single.event, 'reading');
    expect(collected.single.data, {'a': 1});
    expect(fake.lastRequest!.headers['Accept'], 'text/event-stream');
    expect(fake.lastRequest!.headers.containsKey('Authorization'), isFalse);
    expect(fake.lastRequest!.url.toString(), 'https://gw.test/orgs/1/readings/stream');
  });

  test('adjunta Bearer token cuando hay sesión', () async {
    final session = MockSession();
    when(() => session.accessToken).thenReturn('jwt-123');
    when(() => auth.currentSession).thenReturn(session);

    final sub = client.events('/x').listen((_) {});
    await Future<void>.delayed(Duration.zero);
    expect(fake.lastRequest!.headers['Authorization'], 'Bearer jwt-123');
    await sub.cancel();
  });

  test('une data multilínea con saltos de línea', () async {
    final future = client.events('/x').first;

    fake.addLines('data: {"text":\ndata: "hola"}\n\n');
    final event = await future;

    expect(event.data, {'text': 'hola'});
  });

  test('ignora heartbeats (comentarios), id:, retry: y data no-JSON', () async {
    final events = client.events('/x');
    final collected = <SseEvent>[];
    final done = events.listen(collected.add).asFuture<void>().catchError((_) {});

    fake.addLines(': keep-alive\n\n');
    fake.addLines('id: 7\nretry: 5000\ndata: not-json\n\n');
    fake.addLines('data: [1,2,3]\n\n'); // JSON pero no objeto → skip
    fake.addLines('data: {"ok":true}\n\n');
    await Future<void>.delayed(Duration.zero);
    await fake.body.close();
    await done;

    expect(collected, hasLength(1));
    expect(collected.single.data, {'ok': true});
  });

  test('filtra por eventName cuando se indica', () async {
    final events = client.events('/x', eventName: 'reading');
    final collected = <SseEvent>[];
    final done = events.listen(collected.add).asFuture<void>().catchError((_) {});

    fake.addLines('event: presence\ndata: {"p":1}\n\n');
    fake.addLines('event: reading\ndata: {"r":1}\n\n');
    await Future<void>.delayed(Duration.zero);
    await fake.body.close();
    await done;

    expect(collected, hasLength(1));
    expect(collected.single.data, {'r': 1});
  });

  test('cancelar la suscripción cierra el http.Client (aborta el socket)', () async {
    final sub = client.events('/x').listen((_) {});
    await Future<void>.delayed(Duration.zero);

    await sub.cancel();

    expect(fake.closed, isTrue);
  });

  test('lanza ApiGatewayException en respuesta no-2xx con message del body', () async {
    fake = FakeStreamingClient(statusCode: 403);
    client = buildClient();
    fake.addLines('{"message":"Prohibido"}');
    unawaited(fake.body.close());

    await expectLater(
      client.events('/x').first,
      throwsA(
        isA<ApiGatewayException>()
            .having((e) => e.statusCode, 'statusCode', 403)
            .having((e) => e.message, 'message', 'Prohibido'),
      ),
    );
  });

  test('falla rápido cuando API_GATEWAY_URL está vacía', () async {
    client = buildClient(baseUrl: '');

    await expectLater(
      client.events('/x').first,
      throwsA(
        isA<ApiGatewayException>().having((e) => e.statusCode, 'statusCode', 0),
      ),
    );
  });
}

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> initializeSupabase() async {
  final url = dotenv.env['SUPABASE_URL'];
  final anonKey = dotenv.env['ANON_KEY'];

  if (url == null || url.isEmpty) {
    throw Exception('SUPABASE_URL no está configurada');
  }

  if (anonKey == null || anonKey.isEmpty) {
    throw Exception('ANON_KEY no está configurada');
  }

  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;
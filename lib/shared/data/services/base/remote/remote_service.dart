import 'package:supabase_flutter/supabase_flutter.dart';

abstract class RemoteService {
  final SupabaseClient supabase;

  RemoteService(this.supabase);
}

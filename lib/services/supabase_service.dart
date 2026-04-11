import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Infos de ton projet Supabase
  static const String supabaseUrl = 'https://yywgknbesvqqepczdlxe.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5d2drbmJlc3ZxcWVwY3pkbHhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUxMzY4MzcsImV4cCI6MjA5MDcxMjgzN30.2ekdNU1pQEBpGL-yf5Aw0RDG3ESC9YNJyTsk3sddQmA';

  static late final SupabaseClient client;

  /// Initialise la connexion Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    client = Supabase.instance.client;
  }

  /// Flux de données en temps réel depuis la table "Monitoring"
  static Stream<List<Map<String, dynamic>>> getTelemetryStream() {
    return client
        .from('Monitoring') // Nom EXACT de la table avec la majuscule
        .stream(primaryKey: ['id'])
        .order('id', ascending: true);
  }
}
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class EnvConfig {
  static String get supabaseUrl => dotenv.get('SUPABASE_URL');
  static String get supabaseAnonKey => dotenv.get('SUPABASE_ANON_KEY');

  static void validate() {
    if (supabaseUrl.isEmpty ||
        supabaseAnonKey.isEmpty ||
        supabaseUrl == 'your_supabase_project_url' ||
        supabaseAnonKey == 'your_supabase_anon_key') {
      throw StateError(
        'Add valid SUPABASE_URL and SUPABASE_ANON_KEY values to .env.',
      );
    }
  }
}

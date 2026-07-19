import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService(this.client);

  final SupabaseClient client;

  User? get currentUser => client.auth.currentUser;
  Session? get currentSession => client.auth.currentSession;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;

  Future<User> signIn({required String email, required String password}) async {
    final response = await client.auth.signInWithPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final user = response.user;
    if (user == null) {
      throw const AuthException('Unable to sign in. Please try again.');
    }
    return user;
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    final response = await client.auth.signUp(
      email: email.trim(),
      password: password.trim(),
      data: {'full_name': fullName.trim(), 'phone': phone.trim(), 'role': role},
    );
    final user = response.user ?? currentUser;
    if (user == null) {
      throw const AuthException('Unable to create your account.');
    }
    if (response.session != null) {
      await client.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'role': role,
      }, onConflict: 'id');
    }
    return response.session != null;
  }

  Future<Map<String, dynamic>?> findProfile(String userId) {
    return client.from('profiles').select().eq('id', userId).maybeSingle();
  }

  Future<Map<String, dynamic>> fetchProfile(String userId) async {
    final profile = await findProfile(userId);
    if (profile == null) {
      throw const AuthException('Your account profile could not be found.');
    }
    return profile;
  }

  Future<Map<String, dynamic>?> ensureProfile(User user) async {
    final existingProfile = await findProfile(user.id);
    if (existingProfile != null) return existingProfile;

    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final email = user.email ?? '';
    final metadataRole = metadata['role'] as String?;
    final role = const {'player', 'turf_owner'}.contains(metadataRole)
        ? metadataRole!
        : 'player';
    final metadataName = (metadata['full_name'] as String?)?.trim();
    final fallbackName = email.split('@').first.trim();

    try {
      return await client
          .from('profiles')
          .upsert({
            'id': user.id,
            'full_name': metadataName?.isNotEmpty == true
                ? metadataName
                : (fallbackName.isNotEmpty ? fallbackName : 'TurfVerse User'),
            'email': email,
            'phone': metadata['phone'] as String?,
            'role': role,
          }, onConflict: 'id')
          .select()
          .maybeSingle();
    } on PostgrestException catch (error, stackTrace) {
      debugPrint('Unable to create profile after login: ${error.message}');
      debugPrintStack(stackTrace: stackTrace);
      return findProfile(user.id);
    }
  }

  Future<void> sendPasswordReset(String email) {
    return client.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> signOut() => client.auth.signOut();

  Future<void> requestAccountDeletion(String? reason) async {
    final user = currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw const AuthException(
        'You must be logged in to submit this request.',
      );
    }

    await client.from('deletion_requests').insert({
      'user_id': user.id,
      'email': email,
      'reason': reason?.trim().isEmpty ?? true ? null : reason!.trim(),
      'status': 'pending',
    });
  }
}

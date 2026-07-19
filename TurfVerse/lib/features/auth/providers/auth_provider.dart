import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turfverse/core/services/supabase_service.dart';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(Supabase.instance.client);
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseServiceProvider).authStateChanges;
});

final authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

class LoginResult {
  const LoginResult({required this.role, this.profile});

  final String role;
  final Map<String, dynamic>? profile;
}

class SignUpResult {
  const SignUpResult({required this.hasSession});

  final bool hasSession;
}

class AuthController extends Notifier<AsyncValue<void>> {
  SupabaseService get _service => ref.read(supabaseServiceProvider);

  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<LoginResult?> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    try {
      await _service.signIn(email: email, password: password);
      final user = _service.currentUser;
      if (user == null) {
        throw const AuthException('Unable to access the signed-in account.');
      }
      final uid = user.id;
      Map<String, dynamic>? profile;
      try {
        profile = await _service.findProfile(uid);
        profile ??= await _service.ensureProfile(user);
      } on Object catch (error, stackTrace) {
        debugPrint('Unable to load profile after login: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      final profileRole = profile?['role'] as String?;
      final metadataRole = user.userMetadata?['role'] as String?;
      final role =
          _supportedRole(profileRole) ?? _selfServiceRole(metadataRole);
      state = const AsyncData(null);
      return LoginResult(role: role ?? 'player', profile: profile);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }

  Future<SignUpResult?> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    state = const AsyncLoading();
    try {
      final hasSession = await _service.signUp(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      state = const AsyncData(null);
      return SignUpResult(hasSession: hasSession);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return null;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    state = const AsyncLoading();
    try {
      await _service.sendPasswordReset(email);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> logout() async {
    state = const AsyncLoading();
    try {
      await _service.signOut();
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> requestAccountDeletion(String? reason) async {
    state = const AsyncLoading();
    try {
      await _service.requestAccountDeletion(reason);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}

String authErrorMessage(Object error) {
  if (error is TimeoutException) {
    return 'The request timed out. Check your connection and try again.';
  }
  final message = switch (error) {
    AuthException(:final message) => message.toLowerCase(),
    PostgrestException(:final message) => message.toLowerCase(),
    _ => error.toString().toLowerCase(),
  };

  if (message.contains('invalid login credentials') ||
      message.contains('invalid credentials')) {
    return 'Invalid email or password.';
  }
  if (message.contains('user not found')) {
    return 'No account was found for that email address.';
  }
  if (message.contains('email not confirmed')) {
    return 'Confirm your email address before logging in.';
  }
  if (message.contains('network') ||
      message.contains('socket') ||
      message.contains('connection') ||
      message.contains('failed host lookup') ||
      message.contains('fetch')) {
    return 'Unable to connect. Check your internet connection and try again.';
  }
  if (error is PostgrestException) {
    return 'We could not load your account details. Please try again.';
  }
  return 'Unable to complete the request. Please try again.';
}

String? _supportedRole(String? role) =>
    const {'player', 'turf_owner', 'admin'}.contains(role) ? role : null;

String? _selfServiceRole(String? role) =>
    const {'player', 'turf_owner'}.contains(role) ? role : null;

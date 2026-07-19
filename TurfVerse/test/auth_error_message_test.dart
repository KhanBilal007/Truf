import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';

void main() {
  group('authErrorMessage', () {
    test('maps invalid credentials to a clean message', () {
      expect(
        authErrorMessage(const AuthException('Invalid login credentials')),
        'Invalid email or password.',
      );
    });

    test('maps missing users to a clean message', () {
      expect(
        authErrorMessage(const AuthException('User not found')),
        'No account was found for that email address.',
      );
    });

    test('maps network failures to a clean message', () {
      expect(
        authErrorMessage(Exception('Network connection failed')),
        'Unable to connect. Check your internet connection and try again.',
      );
    });

    test('maps timeouts to a clean message', () {
      expect(
        authErrorMessage(TimeoutException('Request timed out')),
        'The request timed out. Check your connection and try again.',
      );
    });

    test('does not expose raw database errors', () {
      expect(
        authErrorMessage(
          const PostgrestException(message: 'sensitive database detail'),
        ),
        'We could not load your account details. Please try again.',
      );
    });
  });
}

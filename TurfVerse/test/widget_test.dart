import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turfverse/core/router/app_router.dart';
import 'package:turfverse/core/services/supabase_service.dart';
import 'package:turfverse/features/admin/providers/admin_provider.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/main.dart';

void main() {
  final signedOutService = SupabaseService(
    SupabaseClient('https://example.supabase.co', 'test-anon-key'),
  );

  testWidgets('signed-out startup opens login', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseServiceProvider.overrideWithValue(signedOutService),
        ],
        child: const TurfVerseApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
  });

  testWidgets('opens the real login screen from onboarding', (tester) async {
    late GoRouter router;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseServiceProvider.overrideWithValue(signedOutService),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            router = ref.read(appRouterProvider);
            return const TurfVerseApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.go('/onboarding');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Create New Account'), findsOneWidget);
  });

  testWidgets('player dashboard exposes player routes and placeholders', (
    tester,
  ) async {
    late GoRouter router;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseServiceProvider.overrideWithValue(signedOutService),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            router = ref.read(appRouterProvider);
            return const TurfVerseApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.go('/player-dashboard');
    await tester.pumpAndSettle();

    expect(find.text('Welcome to TurfVerse'), findsOneWidget);
    expect(find.text('Complete Your Cricket Profile'), findsOneWidget);

    expect(find.text('Find Matches'), findsOneWidget);
    expect(find.text('Book Turf'), findsOneWidget);
    expect(find.text('My Bookings'), findsOneWidget);
    expect(find.text('My Teams'), findsOneWidget);

    await tester.ensureVisible(find.text('My Stats'));
    await tester.tap(find.text('My Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Your Cricket Stats'), findsOneWidget);
    expect(find.text('Matches Played'), findsOneWidget);
  });

  testWidgets('owner dashboard route exposes business actions', (tester) async {
    late GoRouter router;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseServiceProvider.overrideWithValue(signedOutService),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            router = ref.read(appRouterProvider);
            return const TurfVerseApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.go('/owner-dashboard');
    await tester.pumpAndSettle();

    expect(find.text('Turf Owner Dashboard'), findsOneWidget);
    expect(find.text('My Turfs'), findsOneWidget);
    expect(find.text('Bookings'), findsOneWidget);
    expect(find.text('Revenue Summary'), findsOneWidget);
  });

  testWidgets('compliance route opens and non-admin is denied admin access', (
    tester,
  ) async {
    late GoRouter router;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          supabaseServiceProvider.overrideWithValue(signedOutService),
          isAdminProvider.overrideWith((ref) async => false),
        ],
        child: Consumer(
          builder: (context, ref, child) {
            router = ref.read(appRouterProvider);
            return const TurfVerseApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    router.go('/privacy-policy');
    await tester.pumpAndSettle();
    expect(find.text('Privacy Policy'), findsOneWidget);

    router.go('/admin-dashboard');
    await tester.pumpAndSettle();
    expect(find.text('Access Denied'), findsOneWidget);
  });
}

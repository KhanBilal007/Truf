import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';

class AuthGateScreen extends ConsumerStatefulWidget {
  const AuthGateScreen({super.key});

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_resolveSession);
  }

  Future<void> _resolveSession() async {
    final service = ref.read(supabaseServiceProvider);
    if (service.currentSession == null || service.currentUser == null) {
      if (mounted) context.go(AppRoutes.login);
      return;
    }

    try {
      final user = service.currentUser!;
      final profile = await service.ensureProfile(user);
      if (!mounted) return;

      final route = switch (profile?['role']) {
        'turf_owner' => AppRoutes.ownerDashboard,
        'admin' => AppRoutes.adminDashboard,
        _ => AppRoutes.playerDashboard,
      };
      context.go(route);
    } on Object {
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: LoadingWidget()));
  }
}

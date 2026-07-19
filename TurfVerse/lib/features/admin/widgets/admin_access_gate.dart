import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/features/admin/providers/admin_provider.dart';

class AdminAccessGate extends ConsumerWidget {
  const AdminAccessGate({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(isAdminProvider)
        .when(
          loading: () => const SizedBox(height: 300, child: LoadingWidget()),
          error: (error, stackTrace) =>
              ErrorStateWidget(message: error.toString()),
          data: (isAdmin) => isAdmin
              ? child
              : const ErrorStateWidget(
                  title: 'Access Denied',
                  message: 'You do not have permission to view this page.',
                ),
        );
  }
}

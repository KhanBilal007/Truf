import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/auth/widgets/account_action_tile.dart';

class AccountSettingsScreen extends ConsumerWidget {
  const AccountSettingsScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(authControllerProvider.notifier).logout();
    if (!context.mounted) return;
    if (success) {
      context.go(AppRoutes.onboarding);
      return;
    }
    final error = ref.read(authControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authErrorMessage(error ?? Exception()))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return PremiumPage(
      title: 'Account Settings',
      subtitle: 'Manage your account, support, and privacy options.',
      icon: Icons.manage_accounts_outlined,
      child: PremiumCard(
        child: Column(
          children: [
            AccountActionTile(
              label: 'Privacy Policy',
              icon: Icons.privacy_tip_outlined,
              onTap: () => context.push(AppRoutes.privacyPolicy),
            ),
            const Divider(),
            AccountActionTile(
              label: 'Terms & Conditions',
              icon: Icons.description_outlined,
              onTap: () => context.push(AppRoutes.terms),
            ),
            const Divider(),
            AccountActionTile(
              label: 'Contact Support',
              icon: Icons.support_agent_outlined,
              onTap: () => context.push(AppRoutes.contactSupport),
            ),
            const Divider(),
            AccountActionTile(
              label: 'Report Issue',
              icon: Icons.flag_outlined,
              onTap: () => context.push(AppRoutes.reportIssue),
            ),
            const Divider(),
            AccountActionTile(
              label: 'About App',
              icon: Icons.info_outline_rounded,
              onTap: () => context.push(AppRoutes.aboutApp),
            ),
            const Divider(),
            AccountActionTile(
              label: 'Delete Account',
              icon: Icons.delete_outline_rounded,
              isDanger: true,
              onTap: authState.isLoading
                  ? null
                  : () => context.push(AppRoutes.deleteAccount),
            ),
            const Divider(),
            AccountActionTile(
              label: 'Logout',
              icon: Icons.logout_rounded,
              onTap: authState.isLoading ? null : () => _logout(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

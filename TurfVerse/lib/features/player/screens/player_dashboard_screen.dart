import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';

class PlayerDashboardScreen extends StatelessWidget {
  const PlayerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _DashboardAction(
        label: 'My Profile',
        icon: Icons.person_outline_rounded,
        onTap: () => context.push(AppRoutes.playerProfile),
      ),
      _DashboardAction(
        label: 'Find Matches',
        icon: Icons.groups_outlined,
        onTap: () => context.push(AppRoutes.openMatches),
      ),
      _DashboardAction(
        label: 'Book Turf',
        icon: Icons.stadium_outlined,
        onTap: () => context.push(AppRoutes.turfs),
      ),
      _DashboardAction(
        label: 'My Bookings',
        icon: Icons.event_available_outlined,
        onTap: () => context.push(AppRoutes.myBookings),
      ),
      _DashboardAction(
        label: 'My Teams',
        icon: Icons.shield_outlined,
        onTap: () => context.push(AppRoutes.teams),
      ),
      _DashboardAction(
        label: 'My Stats',
        icon: Icons.bar_chart_rounded,
        onTap: () => context.push(AppRoutes.playerStats),
      ),
      _DashboardAction(
        label: 'Account Settings',
        icon: Icons.manage_accounts_outlined,
        onTap: () => context.push(AppRoutes.accountSettings),
      ),
    ];

    return PremiumPage(
      title: 'Welcome to TurfVerse',
      subtitle: 'Find games, book turfs, and build your local cricket profile.',
      icon: Icons.sports_cricket_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.workspace_premium_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Complete Your Cricket Profile',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                Text(
                  'Add your role, skill level, city, and availability so other '
                  'players can find you.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Edit Profile',
                  icon: Icons.edit_outlined,
                  onPressed: () => context.push(AppRoutes.editPlayerProfile),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text('Explore', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 640 ? 3 : 2;
              final width =
                  (constraints.maxWidth - (16 * (columns - 1))) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final action in actions)
                    SizedBox(width: width, child: action),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardAction extends StatelessWidget {
  const _DashboardAction({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.accent, size: 30),
              const SizedBox(height: 24),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

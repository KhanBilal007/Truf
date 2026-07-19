import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumPage(
      title: 'How do you want to use TurfVerse?',
      subtitle: 'Choose your role to personalize your experience.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cards = [
            _RoleCard(
              icon: Icons.sports_cricket_rounded,
              title: 'I am a Player',
              description:
                  'Join matches, find teams, book turfs, and build your '
                  'cricket profile.',
              buttonLabel: 'Continue as Player',
              onPressed: () => context.go(AppRoutes.placeholderDashboard),
            ),
            _RoleCard(
              icon: Icons.stadium_rounded,
              title: 'I am a Turf Owner',
              description:
                  'Manage turf bookings, slots, customers, and revenue in '
                  'one dashboard.',
              buttonLabel: 'Continue as Turf Owner',
              onPressed: () => context.go(AppRoutes.placeholderDashboard),
            ),
          ];

          if (constraints.maxWidth >= 680) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cards.first),
                const SizedBox(width: 20),
                Expanded(child: cards.last),
              ],
            );
          }

          return Column(
            children: [cards.first, const SizedBox(height: 20), cards.last],
          );
        },
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
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
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(height: 22),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          Text(description, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 26),
          PrimaryButton(
            label: buttonLabel,
            icon: Icons.arrow_forward_rounded,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/player/providers/player_profile_provider.dart';
import 'package:turfverse/features/player/widgets/player_profile_card.dart';

class PlayerProfileScreen extends ConsumerWidget {
  const PlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(playerProfileProvider);

    return PremiumPage(
      title: 'My Cricket Profile',
      subtitle: 'Your player identity across the TurfVerse community.',
      icon: Icons.person_outline_rounded,
      child: profileState.when(
        loading: () => const SizedBox(height: 320, child: LoadingWidget()),
        error: (error, stackTrace) => ErrorStateWidget(
          message: error.toString(),
          actionLabel: 'Try Again',
          onAction: () => ref.read(playerProfileProvider.notifier).refresh(),
        ),
        data: (profile) => Column(
          children: [
            if (profile.isIncomplete) ...[
              EmptyStateWidget(
                title: 'Your cricket profile is incomplete.',
                message:
                    'Add your cricket role, skill level, location, and '
                    'availability to complete it.',
                icon: Icons.person_search_outlined,
                actionLabel: 'Complete Profile',
                onAction: () => context.push(AppRoutes.editPlayerProfile),
              ),
              const SizedBox(height: 22),
            ],
            PlayerProfileCard(profile: profile),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Edit Profile',
              icon: Icons.edit_outlined,
              onPressed: () => context.push(AppRoutes.editPlayerProfile),
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Back to Dashboard',
              icon: Icons.arrow_back_rounded,
              onPressed: () => context.go(AppRoutes.playerDashboard),
            ),
          ],
        ),
      ),
    );
  }
}

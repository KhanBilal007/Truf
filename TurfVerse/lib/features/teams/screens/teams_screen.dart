import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/teams/providers/team_provider.dart';
import 'package:turfverse/features/teams/widgets/team_card.dart';

class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamsState = ref.watch(myTeamsProvider);

    return PremiumPage(
      title: 'My Teams',
      subtitle: 'Create your team and manage your local cricket squad.',
      icon: Icons.groups_rounded,
      child: Column(
        children: [
          PremiumCard(
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Create Team',
                  icon: Icons.add_rounded,
                  onPressed: () => context.push(AppRoutes.createTeam),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Refresh',
                  icon: Icons.refresh_rounded,
                  onPressed: () => ref.invalidate(myTeamsProvider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          teamsState.when(
            loading: () => const SizedBox(height: 300, child: LoadingWidget()),
            error: (error, stackTrace) => ErrorStateWidget(
              message: error.toString(),
              actionLabel: 'Try Again',
              onAction: () => ref.invalidate(myTeamsProvider),
            ),
            data: (teams) {
              if (teams.isEmpty) {
                return EmptyStateWidget(
                  title: 'You have not created or joined any team yet.',
                  message:
                      'Create your first squad and start playing together.',
                  icon: Icons.group_add_outlined,
                  actionLabel: 'Create Your First Team',
                  onAction: () => context.push(AppRoutes.createTeam),
                );
              }
              return Column(
                children: [
                  for (var index = 0; index < teams.length; index++) ...[
                    TeamCard(
                      team: teams[index],
                      onViewTeam: () => context.push(
                        '${AppRoutes.teamDetailBase}/${teams[index].id}',
                      ),
                    ),
                    if (index != teams.length - 1) const SizedBox(height: 18),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

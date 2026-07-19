import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/widgets/custom_text_field.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/player/models/player_profile.dart';
import 'package:turfverse/features/player/widgets/player_stat_card.dart';
import 'package:turfverse/features/teams/models/team.dart';
import 'package:turfverse/features/teams/providers/team_provider.dart';
import 'package:turfverse/features/teams/widgets/team_member_tile.dart';

class TeamDetailScreen extends ConsumerWidget {
  const TeamDetailScreen({required this.teamId, super.key});

  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamState = ref.watch(teamDetailProvider(teamId));

    return PremiumPage(
      title: 'Team Details',
      subtitle: 'Manage your local cricket squad and view team progress.',
      icon: Icons.shield_outlined,
      child: teamState.when(
        loading: () => const SizedBox(height: 320, child: LoadingWidget()),
        error: (error, stackTrace) => ErrorStateWidget(
          message: error.toString(),
          actionLabel: 'Try Again',
          onAction: () => ref.invalidate(teamDetailProvider(teamId)),
        ),
        data: (team) => _TeamDetails(team: team),
      ),
    );
  }
}

class _TeamDetails extends ConsumerStatefulWidget {
  const _TeamDetails({required this.team});

  final Team team;

  @override
  ConsumerState<_TeamDetails> createState() => _TeamDetailsState();
}

class _TeamDetailsState extends ConsumerState<_TeamDetails> {
  final _contactController = TextEditingController();

  @override
  void dispose() {
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _addMember() async {
    final contact = _contactController.text.trim();
    if (contact.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a player email or phone.')),
      );
      return;
    }
    final added = await ref
        .read(teamControllerProvider.notifier)
        .addMember(teamId: widget.team.id, contact: contact);
    if (!mounted) return;
    if (added) {
      _contactController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Player added to team.')));
      return;
    }
    final error = ref.read(teamControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authErrorMessage(error ?? Exception()))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final membersState = ref.watch(teamMembersProvider(team.id));
    final captainState = ref.watch(isTeamCaptainProvider(team.id));
    final actionState = ref.watch(teamControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumCard(
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: AppColors.accent,
                  size: 52,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                team.teamName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(team.city.displayValue),
              const SizedBox(height: 14),
              Text(
                'Captain: ${team.captainName}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text('${team.totalMembers} members'),
              if (!team.description.isBlank) ...[
                const SizedBox(height: 16),
                Text(
                  team.description!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text('Team Members', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        membersState.when(
          loading: () => const SizedBox(height: 220, child: LoadingWidget()),
          error: (error, stackTrace) => ErrorStateWidget(
            message: error.toString(),
            actionLabel: 'Try Again',
            onAction: () => ref.invalidate(teamMembersProvider(team.id)),
          ),
          data: (members) {
            if (members.isEmpty) {
              return const EmptyStateWidget(
                title: 'No team members found.',
                message: 'The captain can add players below.',
                icon: Icons.group_off_outlined,
              );
            }
            return PremiumCard(
              child: Column(
                children: [
                  for (var index = 0; index < members.length; index++) ...[
                    TeamMemberTile(member: members[index]),
                    if (index != members.length - 1) const Divider(),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        captainState.when(
          loading: () => const LinearProgressIndicator(),
          error: (error, stackTrace) => Text(error.toString()),
          data: (isCaptain) => isCaptain
              ? PremiumCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Member',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        label: 'Player email or phone',
                        controller: _contactController,
                        prefixIcon: Icons.person_search_outlined,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        label: 'Add Member',
                        isLoading: actionState.isLoading,
                        onPressed: _addMember,
                      ),
                    ],
                  ),
                )
              : const PremiumCard(
                  child: Text(
                    'Only the team captain can add members.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
        ),
        const SizedBox(height: 30),
        Text('Team Stats', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Team performance tracking will be added in future updates.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth >= 640
                ? (constraints.maxWidth - 16) / 2
                : constraints.maxWidth;
            const stats = [
              PlayerStatCard(
                label: 'Matches Played',
                value: '0',
                icon: Icons.sports_cricket_rounded,
              ),
              PlayerStatCard(
                label: 'Wins',
                value: '0',
                icon: Icons.emoji_events_outlined,
              ),
              PlayerStatCard(
                label: 'Losses',
                value: '0',
                icon: Icons.trending_down_rounded,
              ),
              PlayerStatCard(
                label: 'Win Rate',
                value: '0%',
                icon: Icons.percent_rounded,
              ),
            ];
            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                for (final stat in stats) SizedBox(width: width, child: stat),
              ],
            );
          },
        ),
      ],
    );
  }
}

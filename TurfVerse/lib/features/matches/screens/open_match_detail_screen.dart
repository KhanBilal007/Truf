import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/custom_text_field.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/matches/models/open_match.dart';
import 'package:turfverse/features/matches/providers/open_match_provider.dart';
import 'package:turfverse/features/matches/widgets/match_comment_tile.dart';
import 'package:turfverse/features/player/models/player_profile.dart';
import 'package:turfverse/features/turf/models/turf.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';

class OpenMatchDetailScreen extends ConsumerWidget {
  const OpenMatchDetailScreen({required this.matchId, super.key});

  final String matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchState = ref.watch(openMatchDetailProvider(matchId));

    return PremiumPage(
      title: 'Open Match Details',
      subtitle: 'Review the match, meet participants, and join the chat.',
      icon: Icons.groups_rounded,
      child: matchState.when(
        loading: () => const SizedBox(height: 320, child: LoadingWidget()),
        error: (error, stackTrace) => ErrorStateWidget(
          message: error.toString(),
          actionLabel: 'Try Again',
          onAction: () => ref.invalidate(openMatchDetailProvider(matchId)),
        ),
        data: (match) => _OpenMatchDetails(match: match),
      ),
    );
  }
}

class _OpenMatchDetails extends ConsumerStatefulWidget {
  const _OpenMatchDetails({required this.match});

  final OpenMatch match;

  @override
  ConsumerState<_OpenMatchDetails> createState() => _OpenMatchDetailsState();
}

class _OpenMatchDetailsState extends ConsumerState<_OpenMatchDetails> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _joinMatch() async {
    final joined = await ref
        .read(openMatchControllerProvider.notifier)
        .joinMatch(widget.match.id);
    if (!mounted) return;
    final message = joined
        ? 'You joined the match successfully.'
        : authErrorMessage(
            ref.read(openMatchControllerProvider).error ?? Exception(),
          );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;
    final sent = await ref
        .read(openMatchControllerProvider.notifier)
        .addComment(widget.match.id, comment);
    if (!mounted) return;
    if (sent) {
      _commentController.clear();
      return;
    }
    final error = ref.read(openMatchControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authErrorMessage(error ?? Exception()))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final joinedState = ref.watch(currentPlayerJoinedProvider(match.id));
    final actionState = ref.watch(openMatchControllerProvider);
    final playersState = ref.watch(openMatchPlayersProvider(match.id));
    final commentsState = ref.watch(matchCommentsProvider(match.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      match.turf.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  _MatchStatusBadge(match: match),
                ],
              ),
              const SizedBox(height: 8),
              Text('${match.turf.area}, ${match.turf.city}'),
              const SizedBox(height: 22),
              _MatchDetail(
                label: 'Match date',
                value: formatDate(match.matchDate),
              ),
              _MatchDetail(
                label: 'Start time',
                value: formatTime(match.startTime),
              ),
              _MatchDetail(
                label: 'Players',
                value:
                    '${match.joinedPlayers} joined / '
                    '${match.requiredPlayers} required',
              ),
              _MatchDetail(
                label: 'Skill preference',
                value: formatProfileValue(match.skillPreference),
              ),
              _MatchDetail(
                label: 'Price per player',
                value: formatCurrency(match.pricePerPlayer),
                showDivider: false,
              ),
              const SizedBox(height: 20),
              joinedState.when(
                loading: () => const LinearProgressIndicator(),
                error: (error, stackTrace) => Text(error.toString()),
                data: (alreadyJoined) {
                  if (alreadyJoined) {
                    return const Center(
                      child: Text(
                        'You have already joined this match.',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }
                  if (match.isFull) {
                    return const Center(
                      child: Text(
                        'Match Full',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }
                  if (match.status != 'open') return const SizedBox.shrink();
                  return PrimaryButton(
                    label: 'Join Match',
                    isLoading: actionState.isLoading,
                    onPressed: _joinMatch,
                  );
                },
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Back to Matches',
                icon: Icons.arrow_back_rounded,
                onPressed: () => context.go(AppRoutes.openMatches),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text('Joined Players', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        playersState.when(
          loading: () => const SizedBox(height: 160, child: LoadingWidget()),
          error: (error, stackTrace) => ErrorStateWidget(
            message: error.toString(),
            actionLabel: 'Try Again',
            onAction: () => ref.invalidate(openMatchPlayersProvider(match.id)),
          ),
          data: (players) {
            if (players.isEmpty) {
              return const EmptyStateWidget(
                title: 'No players have joined yet.',
                message: 'Be the first player to join this match.',
                icon: Icons.person_add_alt_1_outlined,
              );
            }
            return PremiumCard(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final player in players)
                    Chip(
                      avatar: const Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                      ),
                      label: Text(
                        '${player.fullName} • '
                        '${formatProfileValue(player.playerRole)} • '
                        '${formatProfileValue(player.skillLevel)}',
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 30),
        Text('Match Chat', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 14),
        PremiumCard(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Write a message...',
                      controller: _commentController,
                      prefixIcon: Icons.chat_bubble_outline_rounded,
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    tooltip: 'Send',
                    onPressed: actionState.isLoading ? null : _sendComment,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              commentsState.when(
                loading: () =>
                    const SizedBox(height: 140, child: LoadingWidget()),
                error: (error, stackTrace) => ErrorStateWidget(
                  message: error.toString(),
                  actionLabel: 'Try Again',
                  onAction: () =>
                      ref.invalidate(matchCommentsProvider(match.id)),
                ),
                data: (comments) {
                  if (comments.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No messages yet.',
                      message: 'Start the match conversation.',
                      icon: Icons.chat_outlined,
                    );
                  }
                  return Column(
                    children: [
                      for (var index = 0; index < comments.length; index++) ...[
                        MatchCommentTile(comment: comments[index]),
                        if (index != comments.length - 1) const Divider(),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MatchDetail extends StatelessWidget {
  const _MatchDetail({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}

class _MatchStatusBadge extends StatelessWidget {
  const _MatchStatusBadge({required this.match});

  final OpenMatch match;

  @override
  Widget build(BuildContext context) {
    final color = match.isFull
        ? AppColors.accent
        : match.status == 'cancelled'
        ? AppColors.danger
        : AppColors.success;
    final label = match.isFull
        ? 'Match Full'
        : formatProfileValue(match.status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

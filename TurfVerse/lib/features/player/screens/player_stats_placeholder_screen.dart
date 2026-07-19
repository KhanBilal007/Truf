import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/player/widgets/player_stat_card.dart';

class PlayerStatsPlaceholderScreen extends StatelessWidget {
  const PlayerStatsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const stats = [
      PlayerStatCard(
        label: 'Matches Played',
        value: '0',
        icon: Icons.sports_cricket_rounded,
      ),
      PlayerStatCard(
        label: 'Runs Scored',
        value: '0',
        icon: Icons.scoreboard_outlined,
      ),
      PlayerStatCard(
        label: 'Wickets Taken',
        value: '0',
        icon: Icons.sports_baseball_outlined,
      ),
      PlayerStatCard(
        label: 'MVP Awards',
        value: '0',
        icon: Icons.emoji_events_outlined,
      ),
    ];

    return PremiumPage(
      title: 'Your Cricket Stats',
      subtitle:
          'Runs, wickets, MVPs, and match history will appear here in future '
          'updates.',
      icon: Icons.bar_chart_rounded,
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth >= 640
                  ? (constraints.maxWidth - 16) / 2
                  : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  for (final stat in stats) SizedBox(width: width, child: stat),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          SecondaryButton(
            label: 'Back to Dashboard',
            icon: Icons.arrow_back_rounded,
            onPressed: () => context.go(AppRoutes.playerDashboard),
          ),
        ],
      ),
    );
  }
}

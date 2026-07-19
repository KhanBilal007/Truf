import 'package:flutter/material.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/features/player/models/player_profile.dart';
import 'package:turfverse/features/teams/models/team.dart';

class TeamCard extends StatelessWidget {
  const TeamCard({required this.team, required this.onViewTeam, super.key});

  final Team team;
  final VoidCallback onViewTeam;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.teamName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(team.city.displayValue),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('Captain: ${team.captainName}'),
          const SizedBox(height: 7),
          Text('${team.totalMembers} members'),
          if (!team.description.isBlank) ...[
            const SizedBox(height: 12),
            Text(
              team.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'View Team',
            icon: Icons.arrow_forward_rounded,
            onPressed: onViewTeam,
          ),
        ],
      ),
    );
  }
}

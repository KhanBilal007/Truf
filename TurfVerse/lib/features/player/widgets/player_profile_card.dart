import 'package:flutter/material.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/features/player/models/player_profile.dart';

class PlayerProfileCard extends StatelessWidget {
  const PlayerProfileCard({required this.profile, super.key});

  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.accent,
            backgroundImage: profile.avatarUrl.isBlank
                ? null
                : NetworkImage(profile.avatarUrl!),
            child: profile.avatarUrl.isBlank
                ? const Icon(Icons.person_rounded, size: 48)
                : null,
          ),
          const SizedBox(height: 18),
          Text(
            profile.fullName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 22),
          _ProfileRow(label: 'Email', value: profile.email),
          _ProfileRow(label: 'Phone', value: profile.phone.displayValue),
          _ProfileRow(label: 'City', value: profile.city.displayValue),
          _ProfileRow(label: 'Area', value: profile.area.displayValue),
          _ProfileRow(
            label: 'Player role',
            value: formatProfileValue(profile.playerRole),
          ),
          _ProfileRow(
            label: 'Skill level',
            value: formatProfileValue(profile.skillLevel),
          ),
          _ProfileRow(
            label: 'Availability',
            value: formatProfileValue(profile.availability),
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
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

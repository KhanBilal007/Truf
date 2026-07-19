import 'package:flutter/material.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/features/matches/models/open_match.dart';
import 'package:turfverse/features/player/models/player_profile.dart';
import 'package:turfverse/features/turf/models/turf.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';

class OpenMatchCard extends StatelessWidget {
  const OpenMatchCard({
    required this.match,
    required this.onViewMatch,
    super.key,
  });

  final OpenMatch match;
  final VoidCallback onViewMatch;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (match.status) {
      'full' => AppColors.accent,
      'cancelled' => AppColors.danger,
      _ => AppColors.success,
    };
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.turf.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text('${match.turf.area}, ${match.turf.city}'),
                  ],
                ),
              ),
              _StatusBadge(
                label: match.isFull ? 'Full' : formatProfileValue(match.status),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _DetailLine(
            icon: Icons.calendar_today_outlined,
            value: formatDate(match.matchDate),
          ),
          _DetailLine(
            icon: Icons.schedule_outlined,
            value: formatTime(match.startTime),
          ),
          _DetailLine(
            icon: Icons.groups_outlined,
            value:
                '${match.joinedPlayers} joined / ${match.requiredPlayers} required',
          ),
          _DetailLine(
            icon: Icons.workspace_premium_outlined,
            value: formatProfileValue(match.skillPreference),
          ),
          _DetailLine(
            icon: Icons.payments_outlined,
            value: '${formatCurrency(match.pricePerPlayer)} per player',
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'View Match',
            icon: Icons.arrow_forward_rounded,
            onPressed: onViewMatch,
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

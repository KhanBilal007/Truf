import 'package:flutter/material.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/features/turf/models/turf.dart';

class TurfCard extends StatelessWidget {
  const TurfCard({required this.turf, required this.onViewDetails, super.key});

  final Turf turf;
  final VoidCallback onViewDetails;

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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.stadium_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      turf.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${turf.area}, ${turf.city}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '${formatCurrency(turf.pricePerHour)} per hour',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (turf.amenities.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final amenity in turf.amenities)
                  Chip(
                    label: Text(amenity),
                    backgroundColor: AppColors.background,
                    side: BorderSide.none,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 22),
          PrimaryButton(
            label: 'View Details',
            icon: Icons.arrow_forward_rounded,
            onPressed: onViewDetails,
          ),
        ],
      ),
    );
  }
}

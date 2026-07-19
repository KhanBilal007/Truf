import 'package:flutter/material.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/turf/models/turf.dart';

class OwnerTurfCard extends StatelessWidget {
  const OwnerTurfCard({
    required this.turf,
    required this.onManageSlots,
    required this.onEdit,
    super.key,
  });

  final Turf turf;
  final VoidCallback onManageSlots;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final statusColor = turf.isActive ? AppColors.success : AppColors.danger;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  turf.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _Badge(
                label: turf.isActive ? 'Active' : 'Inactive',
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('${turf.area}, ${turf.city}'),
          const SizedBox(height: 14),
          Text(
            '${formatCurrency(turf.pricePerHour)} per hour',
            style: const TextStyle(
              color: AppColors.primary,
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
                  Chip(label: Text(amenity)),
              ],
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(label: 'Manage Slots', onPressed: onManageSlots),
          const SizedBox(height: 12),
          SecondaryButton(label: 'Edit Turf', onPressed: onEdit),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

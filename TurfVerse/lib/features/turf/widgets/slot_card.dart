import 'package:flutter/material.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/features/turf/models/turf.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';

class SlotCard extends StatelessWidget {
  const SlotCard({
    required this.slot,
    required this.onBook,
    this.isBooking = false,
    super.key,
  });

  final TurfSlot slot;
  final VoidCallback onBook;
  final bool isBooking;

  @override
  Widget build(BuildContext context) {
    final statusColor = slot.isAvailable ? AppColors.success : AppColors.danger;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatDate(slot.slotDate),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  slot.isAvailable ? 'Available' : 'Booked',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${formatTime(slot.startTime)} - ${formatTime(slot.endTime)}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          Text(
            formatCurrency(slot.price),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (slot.isAvailable) ...[
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Book Slot',
              isLoading: isBooking,
              onPressed: onBook,
            ),
          ],
        ],
      ),
    );
  }
}

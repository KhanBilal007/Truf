import 'package:flutter/material.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/owner/providers/owner_provider.dart';
import 'package:turfverse/features/player/models/player_profile.dart';
import 'package:turfverse/features/turf/models/turf.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';

class OwnerBookingCard extends StatelessWidget {
  const OwnerBookingCard({
    required this.booking,
    this.onMarkPaid,
    this.onCancel,
    this.isLoading = false,
    super.key,
  });

  final OwnerBooking booking;
  final VoidCallback? onMarkPaid;
  final VoidCallback? onCancel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final color = switch (booking.status) {
      'paid' => AppColors.success,
      'cancelled' => AppColors.danger,
      _ => AppColors.accent,
    };
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.playerName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              _StatusBadge(
                label: formatProfileValue(booking.status),
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(booking.turfName),
          const SizedBox(height: 12),
          Text(formatDate(booking.bookingDate)),
          const SizedBox(height: 5),
          Text(
            '${formatTime(booking.startTime)} - ${formatTime(booking.endTime)}',
          ),
          const SizedBox(height: 10),
          Text(
            formatCurrency(booking.amount),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          if (booking.status == 'pending') ...[
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Mark as Paid',
              isLoading: isLoading,
              onPressed: onMarkPaid,
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Cancel Booking',
              onPressed: isLoading ? null : onCancel,
            ),
          ],
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

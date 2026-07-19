import 'package:flutter/material.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/turf/models/booking.dart';
import 'package:turfverse/features/turf/models/turf.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    required this.booking,
    required this.onViewTurf,
    required this.onCancel,
    this.isLoading = false,
    super.key,
  });

  final Booking booking;
  final VoidCallback onViewTurf;
  final VoidCallback onCancel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (booking.status) {
      'paid' => AppColors.success,
      'cancelled' => AppColors.danger,
      _ => AppColors.accent,
    };
    final status =
        booking.status[0].toUpperCase() + booking.status.substring(1);

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  booking.turf.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(formatDate(booking.bookingDate)),
          const SizedBox(height: 6),
          Text(
            '${formatTime(booking.startTime)} - ${formatTime(booking.endTime)}',
          ),
          const SizedBox(height: 10),
          Text(
            formatCurrency(booking.amount),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          PrimaryButton(label: 'View Turf', onPressed: onViewTurf),
          if (booking.status == 'pending') ...[
            const SizedBox(height: 12),
            SecondaryButton(
              label: isLoading ? 'Cancelling...' : 'Cancel Booking',
              onPressed: isLoading ? null : onCancel,
            ),
          ],
        ],
      ),
    );
  }
}

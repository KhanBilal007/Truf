import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/player/models/player_profile.dart';
import 'package:turfverse/features/turf/models/turf.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';
import 'package:turfverse/features/turf/providers/booking_provider.dart';
import 'package:turfverse/features/turf/providers/turf_provider.dart';
import 'package:turfverse/features/turf/widgets/slot_card.dart';

class TurfDetailScreen extends ConsumerWidget {
  const TurfDetailScreen({required this.turfId, super.key});

  final String turfId;

  Future<void> _bookSlot(
    BuildContext context,
    WidgetRef ref,
    TurfSlot slot,
  ) async {
    final success = await ref
        .read(bookingControllerProvider.notifier)
        .bookSlot(slot);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Booking created successfully. Payment status is pending.',
          ),
        ),
      );
      context.go(AppRoutes.myBookings);
      return;
    }
    final error = ref.read(bookingControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authErrorMessage(error ?? Exception()))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turfState = ref.watch(turfDetailProvider(turfId));

    return PremiumPage(
      title: 'Turf Details',
      subtitle: 'Review the venue and reserve an available cricket slot.',
      icon: Icons.stadium_rounded,
      child: turfState.when(
        loading: () => const SizedBox(height: 320, child: LoadingWidget()),
        error: (error, stackTrace) => ErrorStateWidget(
          message: error.toString(),
          actionLabel: 'Try Again',
          onAction: () => ref.invalidate(turfDetailProvider(turfId)),
        ),
        data: (turf) => _TurfDetails(
          turf: turf,
          onBook: (slot) => _bookSlot(context, ref, slot),
        ),
      ),
    );
  }
}

class _TurfDetails extends ConsumerWidget {
  const _TurfDetails({required this.turf, required this.onBook});

  final Turf turf;
  final ValueChanged<TurfSlot> onBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slotsState = ref.watch(turfSlotsProvider(turf.id));
    final bookingState = ref.watch(bookingControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PremiumCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  image: turf.imageUrl.isBlank
                      ? null
                      : DecorationImage(
                          image: NetworkImage(turf.imageUrl!),
                          fit: BoxFit.cover,
                        ),
                ),
                child: turf.imageUrl.isBlank
                    ? const Icon(
                        Icons.stadium_rounded,
                        color: AppColors.accent,
                        size: 70,
                      )
                    : null,
              ),
              const SizedBox(height: 22),
              Text(
                turf.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(turf.address.displayValue),
              const SizedBox(height: 5),
              Text('${turf.area}, ${turf.city}'),
              const SizedBox(height: 16),
              Text(
                '${formatCurrency(turf.pricePerHour)} per hour',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (!turf.description.isBlank) ...[
                const SizedBox(height: 16),
                Text(
                  turf.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (turf.amenities.isNotEmpty) ...[
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final amenity in turf.amenities)
                      Chip(label: Text(amenity)),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text('Available Slots', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Online payment will be available soon.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 18),
        slotsState.when(
          loading: () => const SizedBox(height: 220, child: LoadingWidget()),
          error: (error, stackTrace) => ErrorStateWidget(
            message: error.toString(),
            actionLabel: 'Try Again',
            onAction: () => ref.invalidate(turfSlotsProvider(turf.id)),
          ),
          data: (slots) {
            if (slots.isEmpty) {
              return const EmptyStateWidget(
                title: 'No slots available.',
                message: 'Please check this turf again later.',
                icon: Icons.event_busy_outlined,
              );
            }
            return Column(
              children: [
                for (var index = 0; index < slots.length; index++) ...[
                  SlotCard(
                    slot: slots[index],
                    isBooking: bookingState.isLoading,
                    onBook: () => onBook(slots[index]),
                  ),
                  if (index != slots.length - 1) const SizedBox(height: 16),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/turf/models/booking.dart';
import 'package:turfverse/features/turf/providers/booking_provider.dart';
import 'package:turfverse/features/turf/widgets/booking_card.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    Booking booking,
  ) async {
    final success = await ref
        .read(bookingControllerProvider.notifier)
        .cancelBooking(booking);
    if (!context.mounted) return;
    final message = success
        ? 'Booking cancelled successfully.'
        : authErrorMessage(
            ref.read(bookingControllerProvider).error ?? Exception(),
          );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsState = ref.watch(myBookingsProvider);
    final bookingAction = ref.watch(bookingControllerProvider);

    return PremiumPage(
      title: 'My Bookings',
      subtitle: 'Manage your turf reservations and manual payment status.',
      icon: Icons.event_available_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Online payment will be available soon.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          bookingsState.when(
            loading: () => const SizedBox(height: 320, child: LoadingWidget()),
            error: (error, stackTrace) => ErrorStateWidget(
              message: error.toString(),
              actionLabel: 'Try Again',
              onAction: () => ref.invalidate(myBookingsProvider),
            ),
            data: (bookings) {
              if (bookings.isEmpty) {
                return EmptyStateWidget(
                  title: 'No bookings yet.',
                  message: 'Find a nearby turf and reserve your first slot.',
                  icon: Icons.event_note_outlined,
                  actionLabel: 'Book a Turf',
                  onAction: () => context.go(AppRoutes.turfs),
                );
              }
              return Column(
                children: [
                  for (var index = 0; index < bookings.length; index++) ...[
                    BookingCard(
                      booking: bookings[index],
                      isLoading: bookingAction.isLoading,
                      onViewTurf: () => context.push(
                        '${AppRoutes.turfDetailBase}/${bookings[index].turfId}',
                      ),
                      onCancel: () => _cancel(context, ref, bookings[index]),
                    ),
                    if (index != bookings.length - 1)
                      const SizedBox(height: 18),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

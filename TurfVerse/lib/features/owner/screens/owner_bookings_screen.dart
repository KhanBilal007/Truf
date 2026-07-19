import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/owner/providers/owner_provider.dart';
import 'package:turfverse/features/owner/widgets/owner_booking_card.dart';

class OwnerBookingsScreen extends ConsumerWidget {
  const OwnerBookingsScreen({super.key});

  Future<void> _update(
    BuildContext context,
    WidgetRef ref,
    String id,
    String status,
  ) async {
    final success = await ref
        .read(ownerControllerProvider.notifier)
        .updateBookingStatus(id, status);
    if (!context.mounted) return;
    final message = success
        ? status == 'paid'
              ? 'Booking marked as paid.'
              : 'Booking cancelled successfully.'
        : authErrorMessage(
            ref.read(ownerControllerProvider).error ?? Exception(),
          );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsState = ref.watch(ownerBookingsProvider);
    final actionState = ref.watch(ownerControllerProvider);
    return PremiumPage(
      title: 'Bookings',
      subtitle: 'Track all bookings for your turfs.',
      icon: Icons.event_available_outlined,
      child: bookingsState.when(
        loading: () => const SizedBox(height: 320, child: LoadingWidget()),
        error: (error, stackTrace) => ErrorStateWidget(
          message: error.toString(),
          actionLabel: 'Try Again',
          onAction: () => ref.invalidate(ownerBookingsProvider),
        ),
        data: (bookings) => bookings.isEmpty
            ? const EmptyStateWidget(
                title: 'No bookings yet.',
                message: 'Bookings for your turfs will appear here.',
                icon: Icons.event_note_outlined,
              )
            : Column(
                children: [
                  for (var index = 0; index < bookings.length; index++) ...[
                    OwnerBookingCard(
                      booking: bookings[index],
                      isLoading: actionState.isLoading,
                      onMarkPaid: () =>
                          _update(context, ref, bookings[index].id, 'paid'),
                      onCancel: () => _update(
                        context,
                        ref,
                        bookings[index].id,
                        'cancelled',
                      ),
                    ),
                    if (index != bookings.length - 1)
                      const SizedBox(height: 18),
                  ],
                ],
              ),
      ),
    );
  }
}

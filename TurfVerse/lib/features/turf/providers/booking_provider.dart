import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/turf/models/booking.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';
import 'package:turfverse/features/turf/providers/turf_provider.dart';

final myBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final user = service.currentUser;
  if (user == null) {
    throw const AuthException('Log in to view your bookings.');
  }
  final profile = await service.fetchProfile(user.id);
  final data = await service.client
      .from('bookings')
      .select('*, turfs!bookings_turf_id_fkey(*)')
      .eq('player_id', profile['id'])
      .order('booking_date', ascending: false)
      .order('start_time', ascending: false);
  return data.map(Booking.fromJson).toList();
});

final bookingControllerProvider =
    NotifierProvider<BookingController, AsyncValue<void>>(
      BookingController.new,
    );

class BookingController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> bookSlot(TurfSlot slot) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(supabaseServiceProvider)
          .client
          .rpc('book_turf_slot', params: {'slot_uuid': slot.id});
      ref.invalidate(turfSlotsProvider(slot.turfId));
      ref.invalidate(myBookingsProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> cancelBooking(Booking booking) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(supabaseServiceProvider)
          .client
          .rpc('cancel_pending_booking', params: {'booking_uuid': booking.id});
      ref.invalidate(turfSlotsProvider(booking.turfId));
      ref.invalidate(myBookingsProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}

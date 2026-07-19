import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/turf/models/turf.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';

class OwnerBooking {
  const OwnerBooking({
    required this.id,
    required this.turfId,
    required this.slotId,
    required this.playerName,
    required this.turfName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.amount,
    required this.status,
  });

  final String id;
  final String turfId;
  final String? slotId;
  final String playerName;
  final String turfName;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final double amount;
  final String status;

  factory OwnerBooking.fromJson(Map<String, dynamic> json) {
    final player = json['profiles'] as Map<String, dynamic>?;
    final turf = json['turfs'] as Map<String, dynamic>?;
    return OwnerBooking(
      id: json['id'] as String,
      turfId: json['turf_id'] as String,
      slotId: json['slot_id'] as String?,
      playerName: player?['full_name'] as String? ?? 'Player',
      turfName: turf?['name'] as String? ?? 'Turf',
      bookingDate: DateTime.parse(json['booking_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
    );
  }
}

class OwnerDashboardStats {
  const OwnerDashboardStats({
    required this.totalTurfs,
    required this.todaysBookings,
    required this.pendingPayments,
    required this.monthlyRevenue,
  });

  final int totalTurfs;
  final int todaysBookings;
  final int pendingPayments;
  final double monthlyRevenue;
}

class OwnerRevenueSummary {
  const OwnerRevenueSummary({
    required this.todaysRevenue,
    required this.monthRevenue,
    required this.pendingAmount,
    required this.totalPaidBookings,
    required this.totalPendingBookings,
    required this.recentPaidBookings,
  });

  final double todaysRevenue;
  final double monthRevenue;
  final double pendingAmount;
  final int totalPaidBookings;
  final int totalPendingBookings;
  final List<OwnerBooking> recentPaidBookings;
}

final ownerProfileIdProvider = FutureProvider<String>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final user = service.currentUser;
  if (user == null) throw const AuthException('Log in to continue.');
  final profile = await service.fetchProfile(user.id);
  if (profile['role'] != 'turf_owner') {
    throw const AuthException('A turf owner account is required.');
  }
  return profile['id'] as String;
});

final ownerTurfsProvider = FutureProvider<List<Turf>>((ref) async {
  final ownerId = await ref.watch(ownerProfileIdProvider.future);
  final data = await ref
      .read(supabaseServiceProvider)
      .client
      .from('turfs')
      .select()
      .eq('owner_id', ownerId)
      .order('name');
  return data.map(Turf.fromJson).toList();
});

final ownerTurfProvider = FutureProvider.family<Turf, String>((ref, id) async {
  final ownerId = await ref.watch(ownerProfileIdProvider.future);
  final data = await ref
      .read(supabaseServiceProvider)
      .client
      .from('turfs')
      .select()
      .eq('id', id)
      .eq('owner_id', ownerId)
      .maybeSingle();
  if (data == null) {
    throw const PostgrestException(message: 'Turf not found.');
  }
  return Turf.fromJson(data);
});

final ownerSlotsProvider = FutureProvider.family<List<TurfSlot>, String>((
  ref,
  turfId,
) async {
  await ref.watch(ownerTurfProvider(turfId).future);
  final data = await ref
      .read(supabaseServiceProvider)
      .client
      .from('turf_slots')
      .select()
      .eq('turf_id', turfId)
      .order('slot_date')
      .order('start_time');
  return data.map(TurfSlot.fromJson).toList();
});

final ownerSlotProvider = FutureProvider.family<TurfSlot, String>((
  ref,
  id,
) async {
  final client = ref.read(supabaseServiceProvider).client;
  final data = await client
      .from('turf_slots')
      .select()
      .eq('id', id)
      .maybeSingle();
  if (data == null) {
    throw const PostgrestException(message: 'Turf slot not found.');
  }
  final slot = TurfSlot.fromJson(data);
  await ref.watch(ownerTurfProvider(slot.turfId).future);
  return slot;
});

final ownerBookingsProvider = FutureProvider<List<OwnerBooking>>((ref) async {
  final turfs = await ref.watch(ownerTurfsProvider.future);
  final ids = turfs.map((turf) => turf.id).toList();
  if (ids.isEmpty) return [];
  final data = await ref
      .read(supabaseServiceProvider)
      .client
      .from('bookings')
      .select(
        '*, profiles!bookings_player_id_fkey(full_name), '
        'turfs!bookings_turf_id_fkey(name)',
      )
      .inFilter('turf_id', ids)
      .order('booking_date', ascending: false)
      .order('start_time', ascending: false);
  return data.map(OwnerBooking.fromJson).toList();
});

final ownerDashboardStatsProvider = FutureProvider<OwnerDashboardStats>((
  ref,
) async {
  final turfs = await ref.watch(ownerTurfsProvider.future);
  final bookings = await ref.watch(ownerBookingsProvider.future);
  final now = DateTime.now();
  bool isToday(DateTime date) =>
      date.year == now.year && date.month == now.month && date.day == now.day;
  final paidThisMonth = bookings.where(
    (booking) =>
        booking.status == 'paid' &&
        booking.bookingDate.year == now.year &&
        booking.bookingDate.month == now.month,
  );
  return OwnerDashboardStats(
    totalTurfs: turfs.length,
    todaysBookings: bookings
        .where((booking) => isToday(booking.bookingDate))
        .length,
    pendingPayments: bookings
        .where((booking) => booking.status == 'pending')
        .length,
    monthlyRevenue: paidThisMonth.fold(
      0,
      (sum, booking) => sum + booking.amount,
    ),
  );
});

final ownerRevenueProvider = FutureProvider<OwnerRevenueSummary>((ref) async {
  final bookings = await ref.watch(ownerBookingsProvider.future);
  final now = DateTime.now();
  final paid = bookings.where((booking) => booking.status == 'paid').toList();
  final pending = bookings
      .where((booking) => booking.status == 'pending')
      .toList();
  bool isToday(DateTime date) =>
      date.year == now.year && date.month == now.month && date.day == now.day;
  bool isMonth(DateTime date) =>
      date.year == now.year && date.month == now.month;
  return OwnerRevenueSummary(
    todaysRevenue: paid
        .where((booking) => isToday(booking.bookingDate))
        .fold(0, (sum, booking) => sum + booking.amount),
    monthRevenue: paid
        .where((booking) => isMonth(booking.bookingDate))
        .fold(0, (sum, booking) => sum + booking.amount),
    pendingAmount: pending.fold(0, (sum, booking) => sum + booking.amount),
    totalPaidBookings: paid.length,
    totalPendingBookings: pending.length,
    recentPaidBookings: paid.take(5).toList(),
  );
});

final ownerControllerProvider =
    NotifierProvider<OwnerController, AsyncValue<void>>(OwnerController.new);

class OwnerController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> saveTurf({
    String? turfId,
    required String name,
    required String city,
    required String area,
    required String address,
    required double price,
    required String description,
    required List<String> amenities,
    required bool isActive,
  }) async {
    state = const AsyncLoading();
    try {
      final ownerId = await ref.read(ownerProfileIdProvider.future);
      final values = {
        'owner_id': ownerId,
        'name': name.trim(),
        'city': city.trim(),
        'area': area.trim(),
        'address': address.trim().isEmpty ? null : address.trim(),
        'price_per_hour': price,
        'description': description.trim().isEmpty ? null : description.trim(),
        'amenities': amenities,
        'is_active': isActive,
      };
      final table = ref.read(supabaseServiceProvider).client.from('turfs');
      if (turfId == null) {
        await table.insert(values);
      } else {
        await table.update(values).eq('id', turfId).eq('owner_id', ownerId);
      }
      ref.invalidate(ownerTurfsProvider);
      if (turfId != null) ref.invalidate(ownerTurfProvider(turfId));
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> saveSlot({
    String? slotId,
    required String turfId,
    required DateTime date,
    required String startTime,
    required String endTime,
    required double price,
    required bool isAvailable,
  }) async {
    state = const AsyncLoading();
    try {
      await ref.read(ownerTurfProvider(turfId).future);
      final values = {
        'turf_id': turfId,
        'slot_date': date.toIso8601String().split('T').first,
        'start_time': startTime,
        'end_time': endTime,
        'price': price,
        'is_available': isAvailable,
      };
      final table = ref.read(supabaseServiceProvider).client.from('turf_slots');
      if (slotId == null) {
        await table.insert(values);
      } else {
        await table.update(values).eq('id', slotId).eq('turf_id', turfId);
      }
      ref.invalidate(ownerSlotsProvider(turfId));
      if (slotId != null) ref.invalidate(ownerSlotProvider(slotId));
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(supabaseServiceProvider)
          .client
          .rpc(
            'owner_update_booking_status',
            params: {'booking_uuid': bookingId, 'new_status': status},
          );
      ref.invalidate(ownerBookingsProvider);
      ref.invalidate(ownerDashboardStatsProvider);
      ref.invalidate(ownerRevenueProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}

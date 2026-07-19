import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';

typedef JsonMap = Map<String, dynamic>;

class AdminStats {
  const AdminStats({
    required this.users,
    required this.turfs,
    required this.bookings,
    required this.openReports,
  });
  final int users;
  final int turfs;
  final int bookings;
  final int openReports;
}

class AdminTurf {
  const AdminTurf(this.data, this.ownerName);
  final JsonMap data;
  final String ownerName;
}

class AdminBooking {
  const AdminBooking(this.data, this.playerName, this.turfName);
  final JsonMap data;
  final String playerName;
  final String turfName;
}

class AdminMatch {
  const AdminMatch(this.data, this.creatorName, this.turfName);
  final JsonMap data;
  final String creatorName;
  final String turfName;
}

class AdminReport {
  const AdminReport(this.data, this.userEmail);
  final JsonMap data;
  final String userEmail;
}

final isAdminProvider = FutureProvider<bool>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final user = service.currentUser;
  if (user == null) return false;
  final profile = await service.fetchProfile(user.id);
  return profile['role'] == 'admin';
});

Future<void> _requireAdmin(Ref ref) async {
  if (!await ref.watch(isAdminProvider.future)) {
    throw const AuthException('Access Denied');
  }
}

final adminUsersProvider = FutureProvider<List<JsonMap>>((ref) async {
  await _requireAdmin(ref);
  final data = await ref
      .read(supabaseServiceProvider)
      .client
      .from('profiles')
      .select()
      .order('created_at', ascending: false);
  return data.cast<JsonMap>();
});

final adminTurfsProvider = FutureProvider<List<AdminTurf>>((ref) async {
  await _requireAdmin(ref);
  final client = ref.read(supabaseServiceProvider).client;
  final profiles = await ref.watch(adminUsersProvider.future);
  final names = {for (final row in profiles) row['id']: row['full_name']};
  final data = await client
      .from('turfs')
      .select()
      .order('created_at', ascending: false);
  return data
      .map(
        (row) => AdminTurf(row, names[row['owner_id']] as String? ?? 'Owner'),
      )
      .toList();
});

final adminBookingsProvider = FutureProvider<List<AdminBooking>>((ref) async {
  await _requireAdmin(ref);
  final data = await ref
      .read(supabaseServiceProvider)
      .client
      .from('bookings')
      .select(
        '*, profiles!bookings_player_id_fkey(full_name), '
        'turfs!bookings_turf_id_fkey(name)',
      )
      .order('created_at', ascending: false);
  return data
      .map(
        (row) => AdminBooking(
          row,
          (row['profiles'] as JsonMap?)?['full_name'] as String? ?? 'Player',
          (row['turfs'] as JsonMap?)?['name'] as String? ?? 'Turf',
        ),
      )
      .toList();
});

final adminMatchesProvider = FutureProvider<List<AdminMatch>>((ref) async {
  await _requireAdmin(ref);
  final data = await ref
      .read(supabaseServiceProvider)
      .client
      .from('open_matches')
      .select(
        '*, profiles!open_matches_created_by_fkey(full_name), '
        'turfs!open_matches_turf_id_fkey(name)',
      )
      .order('created_at', ascending: false);
  return data
      .map(
        (row) => AdminMatch(
          row,
          (row['profiles'] as JsonMap?)?['full_name'] as String? ?? 'Player',
          (row['turfs'] as JsonMap?)?['name'] as String? ?? 'Turf',
        ),
      )
      .toList();
});

final adminReportsProvider = FutureProvider<List<AdminReport>>((ref) async {
  await _requireAdmin(ref);
  final profiles = await ref.watch(adminUsersProvider.future);
  final emails = {for (final row in profiles) row['id']: row['email']};
  final data = await ref
      .read(supabaseServiceProvider)
      .client
      .from('reports')
      .select()
      .order('created_at', ascending: false);
  return data
      .map(
        (row) => AdminReport(
          row,
          emails[row['user_id']] as String? ?? 'Unknown user',
        ),
      )
      .toList();
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  final users = await ref.watch(adminUsersProvider.future);
  final turfs = await ref.watch(adminTurfsProvider.future);
  final bookings = await ref.watch(adminBookingsProvider.future);
  final reports = await ref.watch(adminReportsProvider.future);
  return AdminStats(
    users: users.length,
    turfs: turfs.length,
    bookings: bookings.length,
    openReports: reports
        .where((report) => report.data['status'] == 'open')
        .length,
  );
});

final adminControllerProvider =
    NotifierProvider<AdminController, AsyncValue<void>>(AdminController.new);

class AdminController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> resolveReport(String id) async {
    state = const AsyncLoading();
    try {
      if (!await ref.read(isAdminProvider.future)) {
        throw const AuthException('Access Denied');
      }
      await ref
          .read(supabaseServiceProvider)
          .client
          .from('reports')
          .update({'status': 'resolved'})
          .eq('id', id);
      ref.invalidate(adminReportsProvider);
      ref.invalidate(adminStatsProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}

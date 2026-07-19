import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/player/models/player_profile.dart';

final playerProfileProvider =
    AsyncNotifierProvider<PlayerProfileController, PlayerProfile>(
      PlayerProfileController.new,
    );

class PlayerProfileController extends AsyncNotifier<PlayerProfile> {
  SupabaseClient get _client => ref.read(supabaseServiceProvider).client;

  @override
  Future<PlayerProfile> build() => _fetchProfile();

  Future<PlayerProfile> _fetchProfile() async {
    final user = ref.read(supabaseServiceProvider).currentUser;
    if (user == null) {
      throw const AuthException('Log in to view your player profile.');
    }
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();
    if (data == null) {
      throw const AuthException('Your player profile could not be found.');
    }
    return PlayerProfile.fromJson(data);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetchProfile);
  }

  Future<bool> updateProfile({
    required String fullName,
    required String phone,
    required String city,
    required String area,
    required String playerRole,
    required String skillLevel,
    required String availability,
  }) async {
    final current = state.value;
    if (current == null) return false;

    state = const AsyncLoading();
    try {
      await _client
          .from('profiles')
          .update({
            'full_name': fullName.trim(),
            'phone': phone.trim().isEmpty ? null : phone.trim(),
            'city': city.trim().isEmpty ? null : city.trim(),
            'area': area.trim().isEmpty ? null : area.trim(),
            'player_role': playerRole,
            'skill_level': skillLevel,
            'availability': availability,
          })
          .eq('id', current.id);
      state = AsyncData(await _fetchProfile());
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/teams/models/team.dart';
import 'package:turfverse/features/teams/models/team_member.dart';

final currentProfileIdProvider = FutureProvider<String>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final user = service.currentUser;
  if (user == null) throw const AuthException('Log in to continue.');
  final profile = await service.fetchProfile(user.id);
  return profile['id'] as String;
});

final myTeamsProvider = FutureProvider<List<Team>>((ref) async {
  final client = ref.read(supabaseServiceProvider).client;
  final profileId = await ref.watch(currentProfileIdProvider.future);
  final memberships = await client
      .from('team_members')
      .select('team_id')
      .eq('player_id', profileId);
  final teamIds = memberships
      .map((row) => row['team_id'] as String)
      .toSet()
      .toList();
  if (teamIds.isEmpty) return [];

  final data = await client
      .from('teams')
      .select(
        '*, profiles!teams_captain_id_fkey(full_name), '
        'team_members!team_members_team_id_fkey(id)',
      )
      .inFilter('id', teamIds)
      .order('team_name');
  return data.map(Team.fromJson).toList();
});

final teamDetailProvider = FutureProvider.family<Team, String>((ref, id) async {
  final client = ref.read(supabaseServiceProvider).client;
  final data = await client
      .from('teams')
      .select(
        '*, profiles!teams_captain_id_fkey(full_name), '
        'team_members!team_members_team_id_fkey(id)',
      )
      .eq('id', id)
      .maybeSingle();
  if (data == null) {
    throw const PostgrestException(message: 'Team not found.');
  }
  return Team.fromJson(data);
});

final teamMembersProvider = FutureProvider.family<List<TeamMember>, String>((
  ref,
  teamId,
) async {
  final client = ref.read(supabaseServiceProvider).client;
  final data = await client
      .from('team_members')
      .select(
        '*, profiles!team_members_player_id_fkey('
        'full_name, player_role, skill_level)',
      )
      .eq('team_id', teamId)
      .order('created_at');
  return data.map(TeamMember.fromJson).toList();
});

final isTeamCaptainProvider = FutureProvider.family<bool, String>((
  ref,
  teamId,
) async {
  final profileId = await ref.watch(currentProfileIdProvider.future);
  final team = await ref.watch(teamDetailProvider(teamId).future);
  return team.captainId == profileId;
});

final teamControllerProvider =
    NotifierProvider<TeamController, AsyncValue<void>>(TeamController.new);

class TeamController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> createTeam({
    required String teamName,
    required String city,
    required String description,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(supabaseServiceProvider)
          .client
          .rpc(
            'create_team_with_captain',
            params: {
              'team_name_value': teamName.trim(),
              'city_value': city.trim(),
              'description_value': description.trim(),
            },
          );
      ref.invalidate(myTeamsProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> addMember({
    required String teamId,
    required String contact,
  }) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(supabaseServiceProvider)
          .client
          .rpc(
            'add_team_member',
            params: {'team_uuid': teamId, 'player_contact': contact.trim()},
          );
      ref.invalidate(teamMembersProvider(teamId));
      ref.invalidate(teamDetailProvider(teamId));
      ref.invalidate(myTeamsProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}

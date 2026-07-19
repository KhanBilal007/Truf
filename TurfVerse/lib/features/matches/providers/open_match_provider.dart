import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/matches/models/match_comment.dart';
import 'package:turfverse/features/matches/models/open_match.dart';
import 'package:turfverse/features/matches/models/open_match_player.dart';

class OpenMatchSearch {
  const OpenMatchSearch({this.city = '', this.skillLevel = ''});

  final String city;
  final String skillLevel;

  @override
  bool operator ==(Object other) =>
      other is OpenMatchSearch &&
      other.city == city &&
      other.skillLevel == skillLevel;

  @override
  int get hashCode => Object.hash(city, skillLevel);
}

class CreateOpenMatchInput {
  const CreateOpenMatchInput({
    required this.turfId,
    required this.matchDate,
    required this.startTime,
    required this.requiredPlayers,
    required this.skillPreference,
    required this.pricePerPlayer,
  });

  final String turfId;
  final DateTime matchDate;
  final String startTime;
  final int requiredPlayers;
  final String skillPreference;
  final double pricePerPlayer;
}

final openMatchesProvider =
    FutureProvider.family<List<OpenMatch>, OpenMatchSearch>((
      ref,
      search,
    ) async {
      final client = ref.read(supabaseServiceProvider).client;
      final data = await client
          .from('open_matches')
          .select('*, turfs!open_matches_turf_id_fkey(*)')
          .gte('match_date', DateTime.now().toIso8601String().split('T').first)
          .order('match_date')
          .order('start_time');
      final matches = data.map(OpenMatch.fromJson).toList();
      final city = search.city.trim().toLowerCase();
      return matches.where((match) {
        final cityMatches =
            city.isEmpty || match.turf.city.toLowerCase().contains(city);
        final skillMatches =
            search.skillLevel.isEmpty ||
            match.skillPreference == search.skillLevel;
        return cityMatches && skillMatches;
      }).toList();
    });

final openMatchDetailProvider = FutureProvider.family<OpenMatch, String>((
  ref,
  id,
) async {
  final client = ref.read(supabaseServiceProvider).client;
  final data = await client
      .from('open_matches')
      .select('*, turfs!open_matches_turf_id_fkey(*)')
      .eq('id', id)
      .maybeSingle();
  if (data == null) {
    throw const PostgrestException(message: 'Open match not found.');
  }
  return OpenMatch.fromJson(data);
});

final openMatchPlayersProvider =
    FutureProvider.family<List<OpenMatchPlayer>, String>((ref, matchId) async {
      final client = ref.read(supabaseServiceProvider).client;
      final data = await client
          .from('open_match_players')
          .select(
            '*, profiles!open_match_players_player_id_fkey('
            'full_name, player_role, skill_level)',
          )
          .eq('open_match_id', matchId)
          .eq('status', 'joined')
          .order('created_at');
      return data.map(OpenMatchPlayer.fromJson).toList();
    });

final currentPlayerJoinedProvider = FutureProvider.family<bool, String>((
  ref,
  matchId,
) async {
  final service = ref.read(supabaseServiceProvider);
  final user = service.currentUser;
  if (user == null) return false;
  final profile = await service.fetchProfile(user.id);
  final rows = await service.client
      .from('open_match_players')
      .select('id')
      .eq('open_match_id', matchId)
      .eq('player_id', profile['id'])
      .eq('status', 'joined')
      .limit(1);
  return rows.isNotEmpty;
});

final matchCommentsProvider = FutureProvider.family<List<MatchComment>, String>(
  (ref, matchId) async {
    final client = ref.read(supabaseServiceProvider).client;
    final data = await client
        .from('match_comments')
        .select('*, profiles!match_comments_player_id_fkey(full_name)')
        .eq('open_match_id', matchId)
        .order('created_at', ascending: false);
    return data.map(MatchComment.fromJson).toList();
  },
);

final openMatchControllerProvider =
    NotifierProvider<OpenMatchController, AsyncValue<void>>(
      OpenMatchController.new,
    );

class OpenMatchController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<String> _currentProfileId() async {
    final service = ref.read(supabaseServiceProvider);
    final user = service.currentUser;
    if (user == null) {
      throw const AuthException('Log in to continue.');
    }
    final profile = await service.fetchProfile(user.id);
    return profile['id'] as String;
  }

  Future<bool> createMatch(CreateOpenMatchInput input) async {
    state = const AsyncLoading();
    try {
      final profileId = await _currentProfileId();
      await ref
          .read(supabaseServiceProvider)
          .client
          .from('open_matches')
          .insert({
            'created_by': profileId,
            'turf_id': input.turfId,
            'match_date': input.matchDate.toIso8601String().split('T').first,
            'start_time': input.startTime,
            'required_players': input.requiredPlayers,
            'joined_players': 0,
            'skill_preference': input.skillPreference,
            'price_per_player': input.pricePerPlayer,
            'status': 'open',
          });
      ref.invalidate(openMatchesProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> joinMatch(String matchId) async {
    state = const AsyncLoading();
    try {
      await ref
          .read(supabaseServiceProvider)
          .client
          .rpc('join_open_match', params: {'match_uuid': matchId});
      ref.invalidate(openMatchDetailProvider(matchId));
      ref.invalidate(openMatchPlayersProvider(matchId));
      ref.invalidate(currentPlayerJoinedProvider(matchId));
      ref.invalidate(openMatchesProvider);
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }

  Future<bool> addComment(String matchId, String comment) async {
    state = const AsyncLoading();
    try {
      final profileId = await _currentProfileId();
      await ref
          .read(supabaseServiceProvider)
          .client
          .from('match_comments')
          .insert({
            'open_match_id': matchId,
            'player_id': profileId,
            'comment': comment.trim(),
          });
      ref.invalidate(matchCommentsProvider(matchId));
      state = const AsyncData(null);
      return true;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      return false;
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/turf/models/turf.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';

class TurfSearch {
  const TurfSearch({this.city = '', this.area = ''});

  final String city;
  final String area;

  @override
  bool operator ==(Object other) =>
      other is TurfSearch && other.city == city && other.area == area;

  @override
  int get hashCode => Object.hash(city, area);
}

final turfListProvider = FutureProvider.family<List<Turf>, TurfSearch>((
  ref,
  search,
) async {
  final client = ref.read(supabaseServiceProvider).client;
  final data = await client
      .from('turfs')
      .select()
      .eq('is_active', true)
      .order('name');
  final turfs = data.map(Turf.fromJson).toList();
  final city = search.city.trim().toLowerCase();
  final area = search.area.trim().toLowerCase();
  return turfs.where((turf) {
    final cityMatches = city.isEmpty || turf.city.toLowerCase().contains(city);
    final areaMatches = area.isEmpty || turf.area.toLowerCase().contains(area);
    return cityMatches && areaMatches;
  }).toList();
});

final turfDetailProvider = FutureProvider.family<Turf, String>((ref, id) async {
  final client = ref.read(supabaseServiceProvider).client;
  final data = await client.from('turfs').select().eq('id', id).maybeSingle();
  if (data == null) {
    throw const PostgrestException(message: 'Turf not found.');
  }
  return Turf.fromJson(data);
});

final turfSlotsProvider = FutureProvider.family<List<TurfSlot>, String>((
  ref,
  turfId,
) async {
  final client = ref.read(supabaseServiceProvider).client;
  final data = await client
      .from('turf_slots')
      .select()
      .eq('turf_id', turfId)
      .gte('slot_date', DateTime.now().toIso8601String().split('T').first)
      .order('slot_date')
      .order('start_time');
  return data.map(TurfSlot.fromJson).toList();
});

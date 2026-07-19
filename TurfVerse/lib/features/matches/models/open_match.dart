import 'package:turfverse/features/turf/models/turf.dart';

class OpenMatch {
  const OpenMatch({
    required this.id,
    required this.createdBy,
    required this.turfId,
    required this.matchDate,
    required this.startTime,
    required this.requiredPlayers,
    required this.joinedPlayers,
    required this.skillPreference,
    required this.pricePerPlayer,
    required this.status,
    required this.turf,
  });

  final String id;
  final String createdBy;
  final String turfId;
  final DateTime matchDate;
  final String startTime;
  final int requiredPlayers;
  final int joinedPlayers;
  final String skillPreference;
  final double pricePerPlayer;
  final String status;
  final Turf turf;

  bool get isFull => status == 'full' || joinedPlayers >= requiredPlayers;

  factory OpenMatch.fromJson(Map<String, dynamic> json) {
    return OpenMatch(
      id: json['id'] as String,
      createdBy: json['created_by'] as String,
      turfId: json['turf_id'] as String,
      matchDate: DateTime.parse(json['match_date'] as String),
      startTime: json['start_time'] as String,
      requiredPlayers: json['required_players'] as int,
      joinedPlayers: json['joined_players'] as int? ?? 0,
      skillPreference: json['skill_preference'] as String? ?? 'any',
      pricePerPlayer: (json['price_per_player'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'open',
      turf: Turf.fromJson(json['turfs'] as Map<String, dynamic>),
    );
  }
}

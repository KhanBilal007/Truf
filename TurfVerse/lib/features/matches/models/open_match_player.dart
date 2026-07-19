class OpenMatchPlayer {
  const OpenMatchPlayer({
    required this.id,
    required this.playerId,
    required this.fullName,
    required this.playerRole,
    required this.skillLevel,
  });

  final String id;
  final String playerId;
  final String fullName;
  final String? playerRole;
  final String? skillLevel;

  factory OpenMatchPlayer.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return OpenMatchPlayer(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      fullName: profile?['full_name'] as String? ?? 'Player',
      playerRole: profile?['player_role'] as String?,
      skillLevel: profile?['skill_level'] as String?,
    );
  }
}

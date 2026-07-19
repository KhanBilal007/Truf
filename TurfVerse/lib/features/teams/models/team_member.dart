class TeamMember {
  const TeamMember({
    required this.id,
    required this.playerId,
    required this.fullName,
    required this.playerRole,
    required this.skillLevel,
    required this.memberRole,
  });

  final String id;
  final String playerId;
  final String fullName;
  final String? playerRole;
  final String? skillLevel;
  final String memberRole;

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return TeamMember(
      id: json['id'] as String,
      playerId: json['player_id'] as String,
      fullName: profile?['full_name'] as String? ?? 'Player',
      playerRole: profile?['player_role'] as String?,
      skillLevel: profile?['skill_level'] as String?,
      memberRole: json['role'] as String? ?? 'member',
    );
  }
}

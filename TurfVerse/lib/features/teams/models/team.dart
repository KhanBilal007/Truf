class Team {
  const Team({
    required this.id,
    required this.captainId,
    required this.teamName,
    required this.city,
    required this.logoUrl,
    required this.description,
    required this.captainName,
    required this.totalMembers,
  });

  final String id;
  final String captainId;
  final String teamName;
  final String? city;
  final String? logoUrl;
  final String? description;
  final String captainName;
  final int totalMembers;

  factory Team.fromJson(Map<String, dynamic> json) {
    final captain = json['profiles'] as Map<String, dynamic>?;
    final memberRows = json['team_members'] as List<dynamic>? ?? [];
    return Team(
      id: json['id'] as String,
      captainId: json['captain_id'] as String,
      teamName: json['team_name'] as String? ?? '',
      city: json['city'] as String?,
      logoUrl: json['logo_url'] as String?,
      description: json['description'] as String?,
      captainName: captain?['full_name'] as String? ?? 'Captain',
      totalMembers: memberRows.length,
    );
  }
}

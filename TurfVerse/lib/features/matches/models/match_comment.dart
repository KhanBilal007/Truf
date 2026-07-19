class MatchComment {
  const MatchComment({
    required this.id,
    required this.playerName,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String playerName;
  final String comment;
  final DateTime createdAt;

  factory MatchComment.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    return MatchComment(
      id: json['id'] as String,
      playerName: profile?['full_name'] as String? ?? 'Player',
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }
}

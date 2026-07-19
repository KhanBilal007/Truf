class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.area,
    required this.playerRole,
    required this.skillLevel,
    required this.availability,
    required this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? city;
  final String? area;
  final String? playerRole;
  final String? skillLevel;
  final String? availability;
  final String? avatarUrl;

  bool get isIncomplete =>
      fullName.trim().isEmpty ||
      city.isBlank ||
      area.isBlank ||
      playerRole.isBlank ||
      skillLevel.isBlank ||
      availability.isBlank;

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      area: json['area'] as String?,
      playerRole: json['player_role'] as String?,
      skillLevel: json['skill_level'] as String?,
      availability: json['availability'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

extension NullableStringX on String? {
  bool get isBlank => this == null || this!.trim().isEmpty;

  String get displayValue => isBlank ? 'Not added' : this!;
}

String formatProfileValue(String? value) {
  if (value.isBlank) return 'Not added';
  return value!
      .split('_')
      .map(
        (word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

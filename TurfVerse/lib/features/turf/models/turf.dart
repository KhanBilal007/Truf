class Turf {
  const Turf({
    required this.id,
    required this.name,
    required this.city,
    required this.area,
    required this.address,
    required this.pricePerHour,
    required this.description,
    required this.amenities,
    required this.imageUrl,
    required this.ownerId,
    required this.isActive,
  });

  final String id;
  final String name;
  final String city;
  final String area;
  final String? address;
  final double pricePerHour;
  final String? description;
  final List<String> amenities;
  final String? imageUrl;
  final String? ownerId;
  final bool isActive;

  factory Turf.fromJson(Map<String, dynamic> json) {
    return Turf(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      city: json['city'] as String? ?? '',
      area: json['area'] as String? ?? '',
      address: json['address'] as String?,
      pricePerHour: (json['price_per_hour'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      amenities: (json['amenities'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      imageUrl: json['image_url'] as String?,
      ownerId: json['owner_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }
}

String formatCurrency(double value) {
  final amount = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
  return 'Rs $amount';
}

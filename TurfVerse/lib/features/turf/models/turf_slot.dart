class TurfSlot {
  const TurfSlot({
    required this.id,
    required this.turfId,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.isAvailable,
  });

  final String id;
  final String turfId;
  final DateTime slotDate;
  final String startTime;
  final String endTime;
  final double price;
  final bool isAvailable;

  factory TurfSlot.fromJson(Map<String, dynamic> json) {
    return TurfSlot(
      id: json['id'] as String,
      turfId: json['turf_id'] as String,
      slotDate: DateTime.parse(json['slot_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      isAvailable: json['is_available'] as bool? ?? false,
    );
  }
}

String formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatTime(String time) {
  final parts = time.split(':');
  if (parts.length < 2) return time;
  final hour = int.tryParse(parts[0]);
  if (hour == null) return time;
  final suffix = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$displayHour:${parts[1]} $suffix';
}

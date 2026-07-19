import 'package:turfverse/features/turf/models/turf.dart';

class Booking {
  const Booking({
    required this.id,
    required this.turfId,
    required this.slotId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.amount,
    required this.status,
    required this.turf,
  });

  final String id;
  final String turfId;
  final String? slotId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final double amount;
  final String status;
  final Turf turf;

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      turfId: json['turf_id'] as String,
      slotId: json['slot_id'] as String?,
      bookingDate: DateTime.parse(json['booking_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      turf: Turf.fromJson(json['turfs'] as Map<String, dynamic>),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/features/admin/providers/admin_provider.dart';
import 'package:turfverse/features/admin/widgets/admin_access_gate.dart';
import 'package:turfverse/features/admin/widgets/admin_list_card.dart';
import 'package:turfverse/features/player/models/player_profile.dart';
import 'package:turfverse/features/turf/models/turf.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';

class AdminBookingsScreen extends ConsumerStatefulWidget {
  const AdminBookingsScreen({super.key});
  @override
  ConsumerState<AdminBookingsScreen> createState() =>
      _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends ConsumerState<AdminBookingsScreen> {
  String filter = 'all';
  @override
  Widget build(BuildContext context) => PremiumPage(
    title: 'Bookings',
    subtitle: 'Review all turf booking activity.',
    icon: Icons.event_note_outlined,
    child: AdminAccessGate(
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final value in const ['all', 'pending', 'paid', 'cancelled'])
                FilterChip(
                  label: Text(formatProfileValue(value)),
                  selected: filter == value,
                  onSelected: (_) => setState(() => filter = value),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ref
              .watch(adminBookingsProvider)
              .when(
                loading: () =>
                    const SizedBox(height: 260, child: LoadingWidget()),
                error: (error, stackTrace) =>
                    ErrorStateWidget(message: error.toString()),
                data: (bookings) {
                  final rows = filter == 'all'
                      ? bookings
                      : bookings
                            .where(
                              (booking) => booking.data['status'] == filter,
                            )
                            .toList();
                  if (rows.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No bookings found.',
                      message: 'Try another status filter.',
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < rows.length; i++) ...[
                        AdminListCard(
                          title: rows[i].playerName,
                          status: formatProfileValue(
                            rows[i].data['status'] as String?,
                          ),
                          lines: [
                            'Turf: ${rows[i].turfName}',
                            formatDate(
                              DateTime.parse(
                                rows[i].data['booking_date'] as String,
                              ),
                            ),
                            '${formatTime(rows[i].data['start_time'] as String)} - ${formatTime(rows[i].data['end_time'] as String)}',
                            formatCurrency(
                              (rows[i].data['amount'] as num).toDouble(),
                            ),
                          ],
                        ),
                        if (i != rows.length - 1) const SizedBox(height: 14),
                      ],
                    ],
                  );
                },
              ),
        ],
      ),
    ),
  );
}

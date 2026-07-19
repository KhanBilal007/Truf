import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/features/admin/providers/admin_provider.dart';
import 'package:turfverse/features/admin/widgets/admin_access_gate.dart';
import 'package:turfverse/features/admin/widgets/admin_list_card.dart';
import 'package:turfverse/features/turf/models/turf.dart';

class AdminTurfsScreen extends ConsumerWidget {
  const AdminTurfsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => PremiumPage(
    title: 'Turfs',
    subtitle: 'Review all listed cricket grounds.',
    icon: Icons.stadium_outlined,
    child: AdminAccessGate(
      child: ref
          .watch(adminTurfsProvider)
          .when(
            loading: () => const SizedBox(height: 260, child: LoadingWidget()),
            error: (error, stackTrace) =>
                ErrorStateWidget(message: error.toString()),
            data: (turfs) => turfs.isEmpty
                ? const EmptyStateWidget(
                    title: 'No turfs found.',
                    message: 'Turf listings will appear here.',
                  )
                : Column(
                    children: [
                      for (var i = 0; i < turfs.length; i++) ...[
                        AdminListCard(
                          title: turfs[i].data['name'] as String? ?? 'Turf',
                          status: turfs[i].data['is_active'] == true
                              ? 'Active'
                              : 'Inactive',
                          lines: [
                            'Owner: ${turfs[i].ownerName}',
                            '${turfs[i].data['area']}, ${turfs[i].data['city']}',
                            '${formatCurrency((turfs[i].data['price_per_hour'] as num).toDouble())} per hour',
                          ],
                        ),
                        if (i != turfs.length - 1) const SizedBox(height: 14),
                      ],
                    ],
                  ),
          ),
    ),
  );
}

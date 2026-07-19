import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/features/admin/providers/admin_provider.dart';
import 'package:turfverse/features/admin/widgets/admin_access_gate.dart';
import 'package:turfverse/features/admin/widgets/admin_list_card.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/player/models/player_profile.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  Future<void> _resolve(BuildContext context, WidgetRef ref, String id) async {
    final success = await ref
        .read(adminControllerProvider.notifier)
        .resolveReport(id);
    if (!context.mounted) return;
    final message = success
        ? 'Report marked as resolved.'
        : authErrorMessage(
            ref.read(adminControllerProvider).error ?? Exception(),
          );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) => PremiumPage(
    title: 'User Reports',
    subtitle: 'Review and resolve user support and safety reports.',
    icon: Icons.flag_outlined,
    child: AdminAccessGate(
      child: ref
          .watch(adminReportsProvider)
          .when(
            loading: () => const SizedBox(height: 260, child: LoadingWidget()),
            error: (error, stackTrace) =>
                ErrorStateWidget(message: error.toString()),
            data: (reports) => reports.isEmpty
                ? const EmptyStateWidget(
                    title: 'No reports found.',
                    message: 'User reports will appear here.',
                  )
                : Column(
                    children: [
                      for (var i = 0; i < reports.length; i++) ...[
                        AdminListCard(
                          title: formatProfileValue(
                            reports[i].data['report_type'] as String?,
                          ),
                          status: formatProfileValue(
                            reports[i].data['status'] as String?,
                          ),
                          lines: [
                            reports[i].userEmail,
                            reports[i].data['message'] as String? ?? '',
                            formatDate(
                              DateTime.parse(
                                reports[i].data['created_at'] as String,
                              ),
                            ),
                          ],
                          actionLabel: reports[i].data['status'] == 'open'
                              ? 'Mark as Resolved'
                              : null,
                          onAction: reports[i].data['status'] == 'open'
                              ? () => _resolve(
                                  context,
                                  ref,
                                  reports[i].data['id'] as String,
                                )
                              : null,
                        ),
                        if (i != reports.length - 1) const SizedBox(height: 14),
                      ],
                    ],
                  ),
          ),
    ),
  );
}

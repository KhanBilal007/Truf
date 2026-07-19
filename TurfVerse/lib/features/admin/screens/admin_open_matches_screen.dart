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
import 'package:turfverse/features/turf/models/turf_slot.dart';

class AdminOpenMatchesScreen extends ConsumerWidget {
  const AdminOpenMatchesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => PremiumPage(
    title: 'Open Matches',
    subtitle: 'Review community match activity.',
    icon: Icons.groups_outlined,
    child: AdminAccessGate(
      child: ref
          .watch(adminMatchesProvider)
          .when(
            loading: () => const SizedBox(height: 260, child: LoadingWidget()),
            error: (error, stackTrace) =>
                ErrorStateWidget(message: error.toString()),
            data: (matches) => matches.isEmpty
                ? const EmptyStateWidget(
                    title: 'No open matches found.',
                    message: 'Matches will appear here.',
                  )
                : Column(
                    children: [
                      for (var i = 0; i < matches.length; i++) ...[
                        AdminListCard(
                          title: matches[i].turfName,
                          status: formatProfileValue(
                            matches[i].data['status'] as String?,
                          ),
                          lines: [
                            'Created by: ${matches[i].creatorName}',
                            formatDate(
                              DateTime.parse(
                                matches[i].data['match_date'] as String,
                              ),
                            ),
                            '${matches[i].data['joined_players']} joined / ${matches[i].data['required_players']} required',
                          ],
                        ),
                        if (i != matches.length - 1) const SizedBox(height: 14),
                      ],
                    ],
                  ),
          ),
    ),
  );
}

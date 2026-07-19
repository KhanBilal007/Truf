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

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  String filter = 'all';
  @override
  Widget build(BuildContext context) => PremiumPage(
    title: 'Users',
    subtitle: 'Review TurfVerse accounts and roles.',
    icon: Icons.people_outline,
    child: AdminAccessGate(
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            children: [
              for (final entry in const {
                'all': 'All',
                'player': 'Players',
                'turf_owner': 'Turf Owners',
                'admin': 'Admins',
              }.entries)
                FilterChip(
                  label: Text(entry.value),
                  selected: filter == entry.key,
                  onSelected: (_) => setState(() => filter = entry.key),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ref
              .watch(adminUsersProvider)
              .when(
                loading: () =>
                    const SizedBox(height: 260, child: LoadingWidget()),
                error: (error, stackTrace) =>
                    ErrorStateWidget(message: error.toString()),
                data: (users) {
                  final filtered = filter == 'all'
                      ? users
                      : users.where((user) => user['role'] == filter).toList();
                  if (filtered.isEmpty) {
                    return const EmptyStateWidget(
                      title: 'No users found.',
                      message: 'Try another role filter.',
                    );
                  }
                  return Column(
                    children: [
                      for (var i = 0; i < filtered.length; i++) ...[
                        AdminListCard(
                          title: filtered[i]['full_name'] as String? ?? 'User',
                          status: formatProfileValue(
                            filtered[i]['role'] as String?,
                          ),
                          lines: [
                            filtered[i]['email'] as String? ?? 'No email',
                            filtered[i]['phone'] as String? ?? 'No phone',
                            '${filtered[i]['city'] ?? 'No city'} / ${filtered[i]['area'] ?? 'No area'}',
                          ],
                        ),
                        if (i != filtered.length - 1)
                          const SizedBox(height: 14),
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

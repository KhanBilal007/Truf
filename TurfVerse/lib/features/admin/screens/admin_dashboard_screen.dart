import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/features/admin/providers/admin_provider.dart';
import 'package:turfverse/features/admin/widgets/admin_access_gate.dart';
import 'package:turfverse/features/admin/widgets/admin_stat_card.dart';
import 'package:turfverse/features/owner/widgets/owner_dashboard_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PremiumPage(
      title: 'Admin Dashboard',
      subtitle: 'Manage users, turfs, bookings, matches, and reports.',
      icon: Icons.admin_panel_settings_outlined,
      child: AdminAccessGate(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ref
                .watch(adminStatsProvider)
                .when(
                  loading: () =>
                      const SizedBox(height: 220, child: LoadingWidget()),
                  error: (error, stackTrace) =>
                      ErrorStateWidget(message: error.toString()),
                  data: (stats) => _Grid(
                    children: [
                      AdminStatCard(
                        label: 'Total Users',
                        value: '${stats.users}',
                        icon: Icons.people_outline,
                      ),
                      AdminStatCard(
                        label: 'Total Turfs',
                        value: '${stats.turfs}',
                        icon: Icons.stadium_outlined,
                      ),
                      AdminStatCard(
                        label: 'Total Bookings',
                        value: '${stats.bookings}',
                        icon: Icons.event_note_outlined,
                      ),
                      AdminStatCard(
                        label: 'Open Reports',
                        value: '${stats.openReports}',
                        icon: Icons.flag_outlined,
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 30),
            _Grid(
              children: [
                OwnerDashboardCard(
                  label: 'Users',
                  icon: Icons.people_outline,
                  onTap: () => context.push(AppRoutes.adminUsers),
                ),
                OwnerDashboardCard(
                  label: 'Turfs',
                  icon: Icons.stadium_outlined,
                  onTap: () => context.push(AppRoutes.adminTurfs),
                ),
                OwnerDashboardCard(
                  label: 'Bookings',
                  icon: Icons.event_note_outlined,
                  onTap: () => context.push(AppRoutes.adminBookings),
                ),
                OwnerDashboardCard(
                  label: 'Open Matches',
                  icon: Icons.groups_outlined,
                  onTap: () => context.push(AppRoutes.adminOpenMatches),
                ),
                OwnerDashboardCard(
                  label: 'Reports',
                  icon: Icons.flag_outlined,
                  onTap: () => context.push(AppRoutes.adminReports),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final child in children)
          SizedBox(width: (constraints.maxWidth - 16) / 2, child: child),
      ],
    ),
  );
}

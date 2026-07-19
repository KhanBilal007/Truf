import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/features/owner/providers/owner_provider.dart';
import 'package:turfverse/features/owner/widgets/owner_dashboard_card.dart';
import 'package:turfverse/features/owner/widgets/revenue_summary_card.dart';
import 'package:turfverse/features/turf/models/turf.dart';

class OwnerDashboardScreen extends ConsumerWidget {
  const OwnerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(ownerDashboardStatsProvider);
    final actions = [
      OwnerDashboardCard(
        label: 'My Turfs',
        icon: Icons.stadium_outlined,
        onTap: () => context.push(AppRoutes.ownerTurfs),
      ),
      OwnerDashboardCard(
        label: 'Bookings',
        icon: Icons.event_available_outlined,
        onTap: () => context.push(AppRoutes.ownerBookings),
      ),
      OwnerDashboardCard(
        label: 'Revenue Summary',
        icon: Icons.payments_outlined,
        onTap: () => context.push(AppRoutes.ownerRevenue),
      ),
      OwnerDashboardCard(
        label: 'Account Settings',
        icon: Icons.manage_accounts_outlined,
        onTap: () => context.push(AppRoutes.accountSettings),
      ),
    ];
    return PremiumPage(
      title: 'Turf Owner Dashboard',
      subtitle: 'Manage your turfs, bookings, slots, and revenue.',
      icon: Icons.business_center_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          statsState.when(
            loading: () => const SizedBox(height: 240, child: LoadingWidget()),
            error: (error, stackTrace) => ErrorStateWidget(
              message: error.toString(),
              actionLabel: 'Try Again',
              onAction: () => ref.invalidate(ownerDashboardStatsProvider),
            ),
            data: (stats) => _Grid(
              children: [
                RevenueSummaryCard(
                  label: 'Total Turfs',
                  value: '${stats.totalTurfs}',
                  icon: Icons.stadium_outlined,
                ),
                RevenueSummaryCard(
                  label: "Today's Bookings",
                  value: '${stats.todaysBookings}',
                  icon: Icons.today_outlined,
                ),
                RevenueSummaryCard(
                  label: 'Pending Payments',
                  value: '${stats.pendingPayments}',
                  icon: Icons.pending_actions_outlined,
                ),
                RevenueSummaryCard(
                  label: 'Monthly Revenue',
                  value: formatCurrency(stats.monthlyRevenue),
                  icon: Icons.trending_up_rounded,
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Manage Business',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          _Grid(children: actions),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 640 ? 2 : 2;
        final width = (constraints.maxWidth - 16 * (columns - 1)) / columns;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

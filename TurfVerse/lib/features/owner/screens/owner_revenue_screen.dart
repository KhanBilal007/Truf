import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/features/owner/providers/owner_provider.dart';
import 'package:turfverse/features/owner/widgets/owner_booking_card.dart';
import 'package:turfverse/features/owner/widgets/revenue_summary_card.dart';
import 'package:turfverse/features/turf/models/turf.dart';

class OwnerRevenueScreen extends ConsumerWidget {
  const OwnerRevenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PremiumPage(
      title: 'Revenue Summary',
      subtitle: 'Track paid revenue and pending booking value.',
      icon: Icons.trending_up_rounded,
      child: ref
          .watch(ownerRevenueProvider)
          .when(
            loading: () => const SizedBox(height: 320, child: LoadingWidget()),
            error: (error, stackTrace) => ErrorStateWidget(
              message: error.toString(),
              actionLabel: 'Try Again',
              onAction: () => ref.invalidate(ownerRevenueProvider),
            ),
            data: (summary) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RevenueGrid(
                  children: [
                    RevenueSummaryCard(
                      label: "Today's Revenue",
                      value: formatCurrency(summary.todaysRevenue),
                      icon: Icons.today_outlined,
                    ),
                    RevenueSummaryCard(
                      label: 'This Month Revenue',
                      value: formatCurrency(summary.monthRevenue),
                      icon: Icons.calendar_month_outlined,
                    ),
                    RevenueSummaryCard(
                      label: 'Pending Amount',
                      value: formatCurrency(summary.pendingAmount),
                      icon: Icons.pending_actions_outlined,
                    ),
                    RevenueSummaryCard(
                      label: 'Total Paid Bookings',
                      value: '${summary.totalPaidBookings}',
                      icon: Icons.check_circle_outline_rounded,
                    ),
                    RevenueSummaryCard(
                      label: 'Total Pending Bookings',
                      value: '${summary.totalPendingBookings}',
                      icon: Icons.hourglass_empty_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Text(
                  'Recent Paid Bookings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (summary.recentPaidBookings.isEmpty)
                  const EmptyStateWidget(
                    title: 'No paid bookings yet.',
                    message: 'Paid bookings will appear here.',
                    icon: Icons.receipt_long_outlined,
                  )
                else
                  for (
                    var index = 0;
                    index < summary.recentPaidBookings.length;
                    index++
                  ) ...[
                    OwnerBookingCard(
                      booking: summary.recentPaidBookings[index],
                    ),
                    if (index != summary.recentPaidBookings.length - 1)
                      const SizedBox(height: 16),
                  ],
              ],
            ),
          ),
    );
  }
}

class _RevenueGrid extends StatelessWidget {
  const _RevenueGrid({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth >= 640
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;
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

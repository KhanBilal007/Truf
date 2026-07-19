import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/owner/providers/owner_provider.dart';
import 'package:turfverse/features/turf/models/turf.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';

class OwnerTurfSlotsScreen extends ConsumerWidget {
  const OwnerTurfSlotsScreen({required this.turfId, super.key});
  final String turfId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turfState = ref.watch(ownerTurfProvider(turfId));
    final slotsState = ref.watch(ownerSlotsProvider(turfId));
    return PremiumPage(
      title: 'Manage Slots',
      subtitle: turfState.value?.name ?? 'Manage your turf availability.',
      icon: Icons.schedule_outlined,
      child: Column(
        children: [
          PremiumCard(
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Add Slot',
                  icon: Icons.add_rounded,
                  onPressed: () =>
                      context.push('${AppRoutes.addSlotBase}/$turfId'),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Refresh',
                  icon: Icons.refresh_rounded,
                  onPressed: () => ref.invalidate(ownerSlotsProvider(turfId)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          slotsState.when(
            loading: () => const SizedBox(height: 300, child: LoadingWidget()),
            error: (error, stackTrace) => ErrorStateWidget(
              message: error.toString(),
              actionLabel: 'Try Again',
              onAction: () => ref.invalidate(ownerSlotsProvider(turfId)),
            ),
            data: (slots) => slots.isEmpty
                ? EmptyStateWidget(
                    title: 'No slots added yet.',
                    message: 'Add your first available booking slot.',
                    icon: Icons.event_busy_outlined,
                    actionLabel: 'Add Slot',
                    onAction: () =>
                        context.push('${AppRoutes.addSlotBase}/$turfId'),
                  )
                : Column(
                    children: [
                      for (var index = 0; index < slots.length; index++) ...[
                        _OwnerSlotCard(slot: slots[index]),
                        if (index != slots.length - 1)
                          const SizedBox(height: 16),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _OwnerSlotCard extends StatelessWidget {
  const _OwnerSlotCard({required this.slot});
  final TurfSlot slot;

  @override
  Widget build(BuildContext context) {
    final color = slot.isAvailable ? AppColors.success : AppColors.danger;
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  formatDate(slot.slotDate),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                slot.isAvailable ? 'Available' : 'Booked',
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('${formatTime(slot.startTime)} - ${formatTime(slot.endTime)}'),
          const SizedBox(height: 8),
          Text(
            formatCurrency(slot.price),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          SecondaryButton(
            label: 'Edit',
            onPressed: () =>
                context.push('${AppRoutes.editSlotBase}/${slot.id}'),
          ),
        ],
      ),
    );
  }
}

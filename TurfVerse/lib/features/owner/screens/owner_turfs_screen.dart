import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/owner/providers/owner_provider.dart';
import 'package:turfverse/features/owner/widgets/owner_turf_card.dart';

class OwnerTurfsScreen extends ConsumerWidget {
  const OwnerTurfsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turfsState = ref.watch(ownerTurfsProvider);
    return PremiumPage(
      title: 'My Turfs',
      subtitle: 'Add and manage your box cricket grounds.',
      icon: Icons.stadium_outlined,
      child: Column(
        children: [
          PremiumCard(
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Add Turf',
                  icon: Icons.add_rounded,
                  onPressed: () => context.push(AppRoutes.addTurf),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Refresh',
                  icon: Icons.refresh_rounded,
                  onPressed: () => ref.invalidate(ownerTurfsProvider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          turfsState.when(
            loading: () => const SizedBox(height: 300, child: LoadingWidget()),
            error: (error, stackTrace) => ErrorStateWidget(
              message: error.toString(),
              actionLabel: 'Try Again',
              onAction: () => ref.invalidate(ownerTurfsProvider),
            ),
            data: (turfs) => turfs.isEmpty
                ? EmptyStateWidget(
                    title: 'You have not added any turf yet.',
                    message: 'Add your first ground to start managing slots.',
                    icon: Icons.add_business_outlined,
                    actionLabel: 'Add Your First Turf',
                    onAction: () => context.push(AppRoutes.addTurf),
                  )
                : Column(
                    children: [
                      for (var index = 0; index < turfs.length; index++) ...[
                        OwnerTurfCard(
                          turf: turfs[index],
                          onManageSlots: () => context.push(
                            '${AppRoutes.ownerTurfSlotsBase}/${turfs[index].id}',
                          ),
                          onEdit: () => context.push(
                            '${AppRoutes.editTurfBase}/${turfs[index].id}',
                          ),
                        ),
                        if (index != turfs.length - 1)
                          const SizedBox(height: 18),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

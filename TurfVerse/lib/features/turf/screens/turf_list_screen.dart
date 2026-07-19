import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/custom_text_field.dart';
import 'package:turfverse/core/widgets/empty_state_widget.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/turf/providers/turf_provider.dart';
import 'package:turfverse/features/turf/widgets/turf_card.dart';

class TurfListScreen extends ConsumerStatefulWidget {
  const TurfListScreen({super.key});

  @override
  ConsumerState<TurfListScreen> createState() => _TurfListScreenState();
}

class _TurfListScreenState extends ConsumerState<TurfListScreen> {
  final _cityController = TextEditingController();
  final _areaController = TextEditingController();
  TurfSearch _search = const TurfSearch();

  @override
  void dispose() {
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _applySearch() {
    setState(() {
      _search = TurfSearch(
        city: _cityController.text.trim(),
        area: _areaController.text.trim(),
      );
    });
  }

  void _clearSearch() {
    _cityController.clear();
    _areaController.clear();
    setState(() => _search = const TurfSearch());
  }

  @override
  Widget build(BuildContext context) {
    final turfsState = ref.watch(turfListProvider(_search));

    return PremiumPage(
      title: 'Book a Turf',
      subtitle: 'Find nearby box cricket turfs and reserve your slot.',
      icon: Icons.stadium_rounded,
      child: Column(
        children: [
          PremiumCard(
            child: Column(
              children: [
                CustomTextField(
                  label: 'City',
                  controller: _cityController,
                  prefixIcon: Icons.location_city_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'Area',
                  controller: _areaController,
                  prefixIcon: Icons.location_on_outlined,
                  textInputAction: TextInputAction.search,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Search',
                  icon: Icons.search_rounded,
                  onPressed: _applySearch,
                ),
                const SizedBox(height: 12),
                SecondaryButton(label: 'Clear', onPressed: _clearSearch),
              ],
            ),
          ),
          const SizedBox(height: 28),
          turfsState.when(
            loading: () => const SizedBox(height: 260, child: LoadingWidget()),
            error: (error, stackTrace) => ErrorStateWidget(
              message: error.toString(),
              actionLabel: 'Try Again',
              onAction: () => ref.invalidate(turfListProvider(_search)),
            ),
            data: (turfs) {
              if (turfs.isEmpty) {
                return const EmptyStateWidget(
                  title: 'No turfs found.',
                  message: 'Try changing your city or area.',
                  icon: Icons.search_off_rounded,
                );
              }
              return Column(
                children: [
                  for (var index = 0; index < turfs.length; index++) ...[
                    TurfCard(
                      turf: turfs[index],
                      onViewDetails: () => context.push(
                        '${AppRoutes.turfDetailBase}/${turfs[index].id}',
                      ),
                    ),
                    if (index != turfs.length - 1) const SizedBox(height: 18),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

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
import 'package:turfverse/features/matches/providers/open_match_provider.dart';
import 'package:turfverse/features/matches/widgets/open_match_card.dart';

class OpenMatchesScreen extends ConsumerStatefulWidget {
  const OpenMatchesScreen({super.key});

  @override
  ConsumerState<OpenMatchesScreen> createState() => _OpenMatchesScreenState();
}

class _OpenMatchesScreenState extends ConsumerState<OpenMatchesScreen> {
  final _cityController = TextEditingController();
  String _skillLevel = '';
  OpenMatchSearch _search = const OpenMatchSearch();

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _search = OpenMatchSearch(
        city: _cityController.text.trim(),
        skillLevel: _skillLevel,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final matchesState = ref.watch(openMatchesProvider(_search));

    return PremiumPage(
      title: 'Find Players & Matches',
      subtitle:
          'Join nearby box cricket matches or create your own open match.',
      icon: Icons.groups_rounded,
      child: Column(
        children: [
          PremiumCard(
            child: Column(
              children: [
                CustomTextField(
                  label: 'City',
                  controller: _cityController,
                  prefixIcon: Icons.location_city_outlined,
                  textInputAction: TextInputAction.search,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _skillLevel,
                  decoration: const InputDecoration(
                    labelText: 'Skill Level',
                    prefixIcon: Icon(Icons.workspace_premium_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Any')),
                    DropdownMenuItem(
                      value: 'beginner',
                      child: Text('Beginner'),
                    ),
                    DropdownMenuItem(
                      value: 'intermediate',
                      child: Text('Intermediate'),
                    ),
                    DropdownMenuItem(
                      value: 'advanced',
                      child: Text('Advanced'),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _skillLevel = value ?? ''),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Create Open Match',
                  icon: Icons.add_rounded,
                  onPressed: () => context.push(AppRoutes.createOpenMatch),
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Refresh',
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    _applyFilters();
                    ref.invalidate(openMatchesProvider(_search));
                  },
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          matchesState.when(
            loading: () => const SizedBox(height: 280, child: LoadingWidget()),
            error: (error, stackTrace) => ErrorStateWidget(
              message: error.toString(),
              actionLabel: 'Try Again',
              onAction: () => ref.invalidate(openMatchesProvider(_search)),
            ),
            data: (matches) {
              if (matches.isEmpty) {
                return EmptyStateWidget(
                  title: 'No open matches found.',
                  message: 'Create a match and invite players nearby.',
                  icon: Icons.group_off_outlined,
                  actionLabel: 'Create Open Match',
                  onAction: () => context.push(AppRoutes.createOpenMatch),
                );
              }
              return Column(
                children: [
                  for (var index = 0; index < matches.length; index++) ...[
                    OpenMatchCard(
                      match: matches[index],
                      onViewMatch: () => context.push(
                        '${AppRoutes.openMatchDetailBase}/${matches[index].id}',
                      ),
                    ),
                    if (index != matches.length - 1) const SizedBox(height: 18),
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

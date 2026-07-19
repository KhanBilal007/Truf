import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/custom_text_field.dart';
import 'package:turfverse/core/widgets/error_state_widget.dart';
import 'package:turfverse/core/widgets/loading_widget.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/matches/providers/open_match_provider.dart';
import 'package:turfverse/features/turf/models/turf_slot.dart';
import 'package:turfverse/features/turf/providers/turf_provider.dart';

class CreateOpenMatchScreen extends ConsumerStatefulWidget {
  const CreateOpenMatchScreen({super.key});

  @override
  ConsumerState<CreateOpenMatchScreen> createState() =>
      _CreateOpenMatchScreenState();
}

class _CreateOpenMatchScreenState extends ConsumerState<CreateOpenMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _requiredPlayersController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _matchDate;
  TimeOfDay? _startTime;
  String? _turfId;
  String _skillPreference = 'any';

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    _requiredPlayersController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _matchDate = date;
        _dateController.text = formatDate(date);
      });
    }
  }

  Future<void> _chooseTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
    );
    if (time != null) {
      setState(() {
        _startTime = time;
        _timeController.text = time.format(context);
      });
    }
  }

  Future<void> _createMatch() async {
    if (!_formKey.currentState!.validate()) return;
    final time = _startTime!;
    final created = await ref
        .read(openMatchControllerProvider.notifier)
        .createMatch(
          CreateOpenMatchInput(
            turfId: _turfId!,
            matchDate: _matchDate!,
            startTime:
                '${time.hour.toString().padLeft(2, '0')}:'
                '${time.minute.toString().padLeft(2, '0')}:00',
            requiredPlayers: int.parse(_requiredPlayersController.text),
            skillPreference: _skillPreference,
            pricePerPlayer: double.parse(_priceController.text),
          ),
        );
    if (!mounted) return;
    if (created) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Open match created successfully.')),
      );
      context.go(AppRoutes.openMatches);
      return;
    }
    final error = ref.read(openMatchControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authErrorMessage(error ?? Exception()))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final turfsState = ref.watch(turfListProvider(const TurfSearch()));
    final actionState = ref.watch(openMatchControllerProvider);

    return PremiumPage(
      title: 'Create Open Match',
      subtitle: 'Choose a turf and invite nearby players to join.',
      icon: Icons.add_circle_outline_rounded,
      child: turfsState.when(
        loading: () => const SizedBox(height: 320, child: LoadingWidget()),
        error: (error, stackTrace) => ErrorStateWidget(
          message: error.toString(),
          actionLabel: 'Try Again',
          onAction: () => ref.invalidate(turfListProvider(const TurfSearch())),
        ),
        data: (turfs) => PremiumCard(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _turfId,
                  decoration: const InputDecoration(
                    labelText: 'Turf',
                    prefixIcon: Icon(Icons.stadium_outlined),
                  ),
                  items: [
                    for (final turf in turfs)
                      DropdownMenuItem(
                        value: turf.id,
                        child: Text('${turf.name} - ${turf.area}'),
                      ),
                  ],
                  validator: (value) => value == null ? 'Select a turf.' : null,
                  onChanged: (value) => setState(() => _turfId = value),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Match Date',
                  controller: _dateController,
                  prefixIcon: Icons.calendar_today_outlined,
                  validator: (value) =>
                      _matchDate == null ? 'Select a match date.' : null,
                  suffixIcon: IconButton(
                    onPressed: _chooseDate,
                    icon: const Icon(Icons.edit_calendar_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Start Time',
                  controller: _timeController,
                  prefixIcon: Icons.schedule_outlined,
                  validator: (value) =>
                      _startTime == null ? 'Select a start time.' : null,
                  suffixIcon: IconButton(
                    onPressed: _chooseTime,
                    icon: const Icon(Icons.access_time_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Required Players',
                  controller: _requiredPlayersController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.groups_outlined,
                  validator: (value) {
                    final number = int.tryParse(value ?? '');
                    return number == null || number <= 0
                        ? 'Required players must be greater than 0.'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Price Per Player',
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: Icons.payments_outlined,
                  validator: (value) {
                    final number = double.tryParse(value ?? '');
                    return number == null || number < 0
                        ? 'Price per player must be 0 or more.'
                        : null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _skillPreference,
                  decoration: const InputDecoration(
                    labelText: 'Skill Preference',
                    prefixIcon: Icon(Icons.workspace_premium_outlined),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'any', child: Text('Any')),
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
                  onChanged: (value) {
                    setState(() => _skillPreference = value ?? 'any');
                  },
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Create Match',
                  isLoading: actionState.isLoading,
                  onPressed: _createMatch,
                ),
                const SizedBox(height: 12),
                SecondaryButton(
                  label: 'Cancel',
                  onPressed: actionState.isLoading
                      ? null
                      : () => context.go(AppRoutes.openMatches),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

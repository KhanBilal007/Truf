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
import 'package:turfverse/features/auth/widgets/auth_validators.dart';
import 'package:turfverse/features/player/models/player_profile.dart';
import 'package:turfverse/features/player/providers/player_profile_provider.dart';

class EditPlayerProfileScreen extends ConsumerWidget {
  const EditPlayerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(playerProfileProvider);

    return PremiumPage(
      title: 'Edit Player Profile',
      subtitle: 'Help local players understand how and where you play.',
      icon: Icons.edit_note_rounded,
      child: profileState.when(
        loading: () => const SizedBox(height: 320, child: LoadingWidget()),
        error: (error, stackTrace) => ErrorStateWidget(
          message: error.toString(),
          actionLabel: 'Try Again',
          onAction: () => ref.read(playerProfileProvider.notifier).refresh(),
        ),
        data: (profile) => _EditPlayerProfileForm(profile: profile),
      ),
    );
  }
}

class _EditPlayerProfileForm extends ConsumerStatefulWidget {
  const _EditPlayerProfileForm({required this.profile});

  final PlayerProfile profile;

  @override
  ConsumerState<_EditPlayerProfileForm> createState() =>
      _EditPlayerProfileFormState();
}

class _EditPlayerProfileFormState
    extends ConsumerState<_EditPlayerProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;
  late final TextEditingController _areaController;
  late String _playerRole;
  late String _skillLevel;
  late String _availability;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _fullNameController = TextEditingController(text: profile.fullName);
    _phoneController = TextEditingController(text: profile.phone);
    _cityController = TextEditingController(text: profile.city);
    _areaController = TextEditingController(text: profile.area);
    _playerRole = profile.playerRole ?? 'batsman';
    _skillLevel = profile.skillLevel ?? 'beginner';
    _availability = profile.availability ?? 'morning';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final saved = await ref
        .read(playerProfileProvider.notifier)
        .updateProfile(
          fullName: _fullNameController.text,
          phone: _phoneController.text,
          city: _cityController.text,
          area: _areaController.text,
          playerRole: _playerRole,
          skillLevel: _skillLevel,
          availability: _availability,
        );
    if (!mounted) return;
    if (saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      context.go(AppRoutes.playerProfile);
      return;
    }
    final error = ref.read(playerProfileProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authErrorMessage(error ?? Exception()))),
    );
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.replaceAll(RegExp(r'[\s()+-]'), '');
    if (!RegExp(r'^\d{7,15}$').hasMatch(normalized)) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(playerProfileProvider).isLoading;

    return PremiumCard(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              label: 'Full Name',
              controller: _fullNameController,
              prefixIcon: Icons.person_outline_rounded,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  AuthValidators.requiredField(value, 'Full name'),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              textInputAction: TextInputAction.next,
              validator: _validatePhone,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'City',
              controller: _cityController,
              prefixIcon: Icons.location_city_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              label: 'Area',
              controller: _areaController,
              prefixIcon: Icons.location_on_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            _ProfileDropdown(
              label: 'Player Role',
              icon: Icons.sports_cricket_outlined,
              value: _playerRole,
              values: const {
                'batsman': 'Batsman',
                'bowler': 'Bowler',
                'all_rounder': 'All-rounder',
                'wicketkeeper': 'Wicketkeeper',
              },
              onChanged: (value) => setState(() => _playerRole = value),
            ),
            const SizedBox(height: 16),
            _ProfileDropdown(
              label: 'Skill Level',
              icon: Icons.workspace_premium_outlined,
              value: _skillLevel,
              values: const {
                'beginner': 'Beginner',
                'intermediate': 'Intermediate',
                'advanced': 'Advanced',
              },
              onChanged: (value) => setState(() => _skillLevel = value),
            ),
            const SizedBox(height: 16),
            _ProfileDropdown(
              label: 'Availability',
              icon: Icons.schedule_outlined,
              value: _availability,
              values: const {
                'morning': 'Morning',
                'afternoon': 'Afternoon',
                'evening': 'Evening',
                'night': 'Night',
              },
              onChanged: (value) => setState(() => _availability = value),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Save Profile',
              isLoading: isLoading,
              onPressed: _save,
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Cancel',
              onPressed: isLoading
                  ? null
                  : () => context.go(AppRoutes.playerProfile),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDropdown extends StatelessWidget {
  const _ProfileDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final IconData icon;
  final String value;
  final Map<String, String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      items: [
        for (final entry in values.entries)
          DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

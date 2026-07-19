import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/custom_text_field.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/auth/widgets/auth_validators.dart';
import 'package:turfverse/features/teams/providers/team_provider.dart';

class CreateTeamScreen extends ConsumerStatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final _teamNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _teamNameController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTeam() async {
    if (!_formKey.currentState!.validate()) return;
    final created = await ref
        .read(teamControllerProvider.notifier)
        .createTeam(
          teamName: _teamNameController.text,
          city: _cityController.text,
          description: _descriptionController.text,
        );
    if (!mounted) return;
    if (created) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Team created successfully.')),
      );
      context.go(AppRoutes.teams);
      return;
    }
    final error = ref.read(teamControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authErrorMessage(error ?? Exception()))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(teamControllerProvider);

    return PremiumPage(
      title: 'Create Team',
      subtitle: 'Build a local squad and bring your cricket circle together.',
      icon: Icons.group_add_outlined,
      child: PremiumCard(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Team Name',
                controller: _teamNameController,
                prefixIcon: Icons.shield_outlined,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    AuthValidators.requiredField(value, 'Team name'),
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
                label: 'Description',
                controller: _descriptionController,
                prefixIcon: Icons.notes_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Create Team',
                isLoading: actionState.isLoading,
                onPressed: _createTeam,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Cancel',
                onPressed: actionState.isLoading
                    ? null
                    : () => context.go(AppRoutes.teams),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

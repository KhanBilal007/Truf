import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turfverse/core/constants/app_colors.dart';
import 'package:turfverse/core/widgets/custom_text_field.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';

class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  final _reasonController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    final success = await ref
        .read(authControllerProvider.notifier)
        .requestAccountDeletion(_reasonController.text);
    if (!mounted) return;
    if (success) {
      setState(() => _submitted = true);
      return;
    }
    final error = ref.read(authControllerProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(authErrorMessage(error ?? Exception()))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return PremiumPage(
      title: 'Delete Account',
      subtitle: 'Submit a secure account deletion request.',
      icon: Icons.delete_forever_outlined,
      child: PremiumCard(
        child: _submitted
            ? Column(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                    size: 54,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your account deletion request has been submitted.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Our support team will process this request.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deleting your account will request removal of your '
                    'profile, bookings, teams, and personal data. Some '
                    'transaction records may be retained if legally required.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.danger),
                  ),
                  const SizedBox(height: 22),
                  CustomTextField(
                    label: 'Reason for deletion (optional)',
                    controller: _reasonController,
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Our support team will process this request.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Request Account Deletion',
                    isLoading: authState.isLoading,
                    onPressed: _submitRequest,
                  ),
                ],
              ),
      ),
    );
  }
}

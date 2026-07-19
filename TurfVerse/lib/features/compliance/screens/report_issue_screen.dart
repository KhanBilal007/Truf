import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/widgets/custom_text_field.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/auth/widgets/auth_validators.dart';
import 'package:turfverse/features/compliance/providers/report_provider.dart';

class ReportIssueScreen extends ConsumerStatefulWidget {
  const ReportIssueScreen({super.key});
  @override
  ConsumerState<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends ConsumerState<ReportIssueScreen> {
  final formKey = GlobalKey<FormState>();
  final message = TextEditingController();
  String type = 'booking_issue';

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final success = await ref
        .read(reportControllerProvider.notifier)
        .submit(type: type, message: message.text);
    if (!mounted) return;
    final text = success
        ? 'Report submitted successfully.'
        : authErrorMessage(
            ref.read(reportControllerProvider).error ?? Exception(),
          );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    if (success) message.clear();
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(reportControllerProvider).isLoading;
    const types = {
      'booking_issue': 'Booking Issue',
      'payment_issue': 'Payment Issue',
      'turf_issue': 'Turf Issue',
      'player_issue': 'Player Issue',
      'technical_issue': 'Technical Issue',
      'other': 'Other',
    };
    return PremiumPage(
      title: 'Report an Issue',
      subtitle: 'Tell us about a safety, booking, or technical problem.',
      icon: Icons.flag_outlined,
      child: PremiumCard(
        child: Form(
          key: formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: type,
                decoration: const InputDecoration(
                  labelText: 'Issue Type',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: [
                  for (final entry in types.entries)
                    DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                ],
                onChanged: (value) => setState(() => type = value ?? 'other'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Message',
                controller: message,
                prefixIcon: Icons.message_outlined,
                maxLines: 5,
                validator: (value) =>
                    AuthValidators.requiredField(value, 'Message'),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: 'Submit Report',
                isLoading: loading,
                onPressed: submit,
              ),
              const SizedBox(height: 12),
              SecondaryButton(
                label: 'Back',
                onPressed: loading ? null : () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

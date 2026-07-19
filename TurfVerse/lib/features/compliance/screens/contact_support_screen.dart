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

class ContactSupportScreen extends ConsumerStatefulWidget {
  const ContactSupportScreen({super.key});
  @override
  ConsumerState<ContactSupportScreen> createState() =>
      _ContactSupportScreenState();
}

class _ContactSupportScreenState extends ConsumerState<ContactSupportScreen> {
  final formKey = GlobalKey<FormState>();
  final subject = TextEditingController();
  final message = TextEditingController();

  @override
  void dispose() {
    subject.dispose();
    message.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final success = await ref
        .read(reportControllerProvider.notifier)
        .submit(
          type: 'support',
          message: 'Subject: ${subject.text.trim()}\n${message.text.trim()}',
        );
    if (!mounted) return;
    final text = success
        ? 'Support request submitted successfully.'
        : authErrorMessage(
            ref.read(reportControllerProvider).error ?? Exception(),
          );
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    if (success) {
      subject.clear();
      message.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(reportControllerProvider).isLoading;
    return PremiumPage(
      title: 'Contact Support',
      subtitle: 'Need help with your account, booking, turf listing, or match?',
      icon: Icons.support_agent_outlined,
      child: PremiumCard(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Email: support@turfverse.in'),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Subject',
                controller: subject,
                prefixIcon: Icons.subject_outlined,
                validator: (value) =>
                    AuthValidators.requiredField(value, 'Subject'),
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
                label: 'Send Support Request',
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

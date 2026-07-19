import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turfverse/core/widgets/custom_text_field.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/auth/widgets/auth_form_card.dart';
import 'package:turfverse/features/auth/widgets/auth_validators.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text);
    if (!mounted) return;

    final message = success
        ? 'Password reset link sent. Please check your email.'
        : authErrorMessage(
            ref.read(authControllerProvider).error ?? Exception(),
          );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return PremiumPage(
      title: 'Reset Password',
      subtitle: 'Enter your email and we will send you a reset link.',
      icon: Icons.mark_email_read_outlined,
      child: AuthFormCard(
        formKey: _formKey,
        child: Column(
          children: [
            CustomTextField(
              label: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              validator: AuthValidators.email,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Send Reset Link',
              isLoading: authState.isLoading,
              onPressed: _sendResetLink,
            ),
          ],
        ),
      ),
    );
  }
}

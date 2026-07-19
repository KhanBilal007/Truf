import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/custom_text_field.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/auth/widgets/auth_form_card.dart';
import 'package:turfverse/features/auth/widgets/auth_validators.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _role = 'player';
  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _showMessage('Please agree to the Terms & Privacy Policy.');
      return;
    }

    final result = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          fullName: _fullNameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
          role: _role,
        );
    if (!mounted) return;
    if (result?.hasSession == true) {
      context.go(
        _role == 'player'
            ? AppRoutes.playerDashboard
            : AppRoutes.ownerDashboard,
      );
    } else if (result == null) {
      final error = ref.read(authControllerProvider).error;
      _showMessage(authErrorMessage(error ?? Exception()));
    } else {
      _showMessage('Check your email to confirm your account, then log in.');
      context.go(AppRoutes.login);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return PremiumPage(
      title: 'Create Your TurfVerse Account',
      subtitle: 'Join the premium cricket community.',
      icon: Icons.person_add_alt_1_rounded,
      child: AuthFormCard(
        formKey: _formKey,
        child: AutofillGroup(
          child: Column(
            children: [
              CustomTextField(
                label: 'Full Name',
                controller: _fullNameController,
                prefixIcon: Icons.person_outline_rounded,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: (value) =>
                    AuthValidators.requiredField(value, 'Full name'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: AuthValidators.email,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                validator: (value) =>
                    AuthValidators.requiredField(value, 'Phone number'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                items: const [
                  DropdownMenuItem(value: 'player', child: Text('Player')),
                  DropdownMenuItem(
                    value: 'turf_owner',
                    child: Text('Turf Owner'),
                  ),
                ],
                onChanged: authState.isLoading
                    ? null
                    : (value) => setState(() => _role = value ?? 'player'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                validator: AuthValidators.password,
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  final error = AuthValidators.requiredField(
                    value,
                    'Confirm password',
                  );
                  if (error != null) return error;
                  if (value != _passwordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _agreedToTerms,
                onChanged: authState.isLoading
                    ? null
                    : (value) =>
                          setState(() => _agreedToTerms = value ?? false),
                title: const Text('I agree to the Terms & Privacy Policy'),
              ),
              const SizedBox(height: 18),
              PrimaryButton(
                label: 'Create Account',
                isLoading: authState.isLoading,
                onPressed: _signUp,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: authState.isLoading
                    ? null
                    : () => context.go(AppRoutes.login),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

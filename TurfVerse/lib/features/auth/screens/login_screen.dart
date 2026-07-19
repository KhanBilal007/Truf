import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/custom_text_field.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';
import 'package:turfverse/features/auth/providers/auth_provider.dart';
import 'package:turfverse/features/auth/widgets/auth_form_card.dart';
import 'package:turfverse/features/auth/widgets/auth_validators.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    if (result == null) {
      _showError();
      return;
    }

    final role = result.role;
    if (role == 'player') {
      context.go(AppRoutes.playerDashboard);
      return;
    }
    if (role == 'turf_owner') {
      context.go(AppRoutes.ownerDashboard);
      return;
    }
    if (role == 'admin') {
      context.go(AppRoutes.adminDashboard);
      return;
    }
    _showMessage('This account role is not supported yet.');
  }

  void _showError() {
    final error = ref.read(authControllerProvider).error;
    _showMessage(authErrorMessage(error ?? Exception()));
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
      title: 'Welcome Back',
      subtitle: 'Login to continue your cricket journey.',
      icon: Icons.login_rounded,
      child: AuthFormCard(
        formKey: _formKey,
        child: AutofillGroup(
          child: Column(
            children: [
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
                label: 'Password',
                controller: _passwordController,
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline_rounded,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                validator: (value) =>
                    AuthValidators.requiredField(value, 'Password'),
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
              const SizedBox(height: 24),
              PrimaryButton(
                label: 'Login',
                isLoading: authState.isLoading,
                onPressed: _login,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: authState.isLoading
                    ? null
                    : () => context.push(AppRoutes.forgotPassword),
                child: const Text('Forgot Password?'),
              ),
              const SizedBox(height: 6),
              SecondaryButton(
                label: 'Create New Account',
                onPressed: authState.isLoading
                    ? null
                    : () => context.push(AppRoutes.signup),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

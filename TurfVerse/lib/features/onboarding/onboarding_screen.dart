import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/primary_button.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumPage(
      title: 'Play More Cricket, Without WhatsApp Chaos',
      subtitle:
          'Find players, book turfs, create teams, and manage local matches '
          'in one premium cricket app.',
      child: PremiumCard(
        child: Column(
          children: [
            PrimaryButton(
              label: 'Get Started',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => context.go(AppRoutes.roleSelection),
            ),
            const SizedBox(height: 14),
            SecondaryButton(
              label: 'Login',
              onPressed: () => context.go(AppRoutes.login),
            ),
          ],
        ),
      ),
    );
  }
}

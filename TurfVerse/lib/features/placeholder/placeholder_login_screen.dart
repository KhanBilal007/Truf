import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';

class PlaceholderLoginScreen extends StatelessWidget {
  const PlaceholderLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumPage(
      title: 'Login',
      subtitle: 'Login will be built in Step 3.',
      icon: Icons.lock_outline_rounded,
      child: PremiumCard(
        child: SecondaryButton(
          label: 'Back to Onboarding',
          icon: Icons.arrow_back_rounded,
          onPressed: () => context.go(AppRoutes.onboarding),
        ),
      ),
    );
  }
}

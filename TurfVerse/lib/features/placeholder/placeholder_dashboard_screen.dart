import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/constants/app_routes.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';

class PlaceholderDashboardScreen extends StatelessWidget {
  const PlaceholderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PremiumPage(
      title: 'Dashboard',
      subtitle: 'Your dashboard will be built in the next steps.',
      icon: Icons.space_dashboard_outlined,
      child: PremiumCard(
        child: SecondaryButton(
          label: 'Back to Role Selection',
          icon: Icons.arrow_back_rounded,
          onPressed: () => context.go(AppRoutes.roleSelection),
        ),
      ),
    );
  }
}

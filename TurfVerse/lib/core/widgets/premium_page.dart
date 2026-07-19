import 'package:flutter/material.dart';
import 'package:turfverse/core/constants/app_colors.dart';

class PremiumPage extends StatelessWidget {
  const PremiumPage({
    required this.title,
    required this.subtitle,
    required this.child,
    this.icon = Icons.sports_cricket_rounded,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: AppColors.accent, size: 28),
                  ),
                  const SizedBox(height: 28),
                  Text(title, style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 14),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 36),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

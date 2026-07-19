import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumPage(
    title: 'About TurfVerse',
    subtitle: 'A premium sports-tech platform for local cricket.',
    icon: Icons.info_outline_rounded,
    child: PremiumCard(
      child: Column(
        children: [
          const Text(
            'TurfVerse helps players find matches, book turfs, create teams, and manage local cricket activity in one premium sports-tech platform.',
          ),
          const SizedBox(height: 20),
          Text(
            'Version: 1.0.0 MVP',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          const Text(
            'Find Players. Book Turfs. Build Your Cricket Profile.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SecondaryButton(label: 'Back', onPressed: () => context.pop()),
        ],
      ),
    ),
  );
}

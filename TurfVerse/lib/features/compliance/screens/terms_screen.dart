import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumPage(
    title: 'Terms & Conditions',
    subtitle: 'Rules for using the TurfVerse MVP.',
    icon: Icons.description_outlined,
    child: PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TurfVerse is a turf cricket booking and community platform.',
          ),
          const SizedBox(height: 20),
          for (final rule in const [
            'No betting, gambling, or fantasy money contests are allowed in this MVP.',
            'Users must provide accurate account information.',
            'Users must behave respectfully with players, turf owners, and organizers.',
            "Turf bookings, cancellations, and refunds may depend on the turf owner's policy.",
            'Fake profiles, spam, abuse, or misuse may lead to account restrictions.',
            'TurfVerse may update these terms as the app grows.',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('• $rule'),
            ),
          const SizedBox(height: 16),
          SecondaryButton(label: 'Back', onPressed: () => context.pop()),
        ],
      ),
    ),
  );
}

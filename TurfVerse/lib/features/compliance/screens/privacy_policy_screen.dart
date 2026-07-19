import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:turfverse/core/widgets/premium_card.dart';
import 'package:turfverse/core/widgets/premium_page.dart';
import 'package:turfverse/core/widgets/secondary_button.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) => PremiumPage(
    title: 'Privacy Policy',
    subtitle: 'How TurfVerse collects and uses your data.',
    icon: Icons.privacy_tip_outlined,
    child: PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TurfVerse collects basic account and app usage data to operate the platform.',
          ),
          const _PolicySection(
            title: 'Data we collect',
            items: [
              'Name',
              'Email',
              'Phone number',
              'City and area',
              'Player profile details',
              'Turf booking data',
              'Match and team data',
              'Support and report messages',
            ],
          ),
          const _PolicySection(
            title: 'How we use data',
            items: [
              'Account creation and login',
              'Turf booking',
              'Player matchmaking',
              'Team and match management',
              'Customer support',
              'Safety and platform improvement',
            ],
          ),
          const _PolicySection(
            title: 'Data deletion',
            items: [
              'Request deletion from Account Settings > Delete Account.',
              'Web deletion requests: https://turfverse.in/delete-account',
            ],
          ),
          const _PolicySection(
            title: 'Contact',
            items: ['support@turfverse.in'],
          ),
          SecondaryButton(label: 'Back', onPressed: () => context.pop()),
        ],
      ),
    ),
  );
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.items});
  final String title;
  final List<String> items;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('• $item'),
          ),
      ],
    ),
  );
}

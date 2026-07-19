import 'package:flutter/material.dart';
import 'package:turfverse/features/owner/widgets/revenue_summary_card.dart';

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return RevenueSummaryCard(label: label, value: value, icon: icon);
  }
}

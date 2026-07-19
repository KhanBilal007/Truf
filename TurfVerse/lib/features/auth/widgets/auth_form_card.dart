import 'package:flutter/material.dart';
import 'package:turfverse/core/widgets/premium_card.dart';

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({required this.formKey, required this.child, super.key});

  final GlobalKey<FormState> formKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Form(key: formKey, child: child),
    );
  }
}

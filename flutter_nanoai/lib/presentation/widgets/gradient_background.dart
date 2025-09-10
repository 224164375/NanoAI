import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.backgroundGradient,
      ),
      child: child,
    );
  }
}

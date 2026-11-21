import 'package:flutter/material.dart';

import '../../style/app_colors.dart';

/// The navy hero field (F26: flat, never a gradient — owner).
///
/// Solid navy-800, the same as the header bands.
class HeroBackground extends StatelessWidget {
  const HeroBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Round 3 (owner): no decorative circles — a plain navy field.
    return ColoredBox(color: AppColors.headerCustomer, child: child);
  }
}

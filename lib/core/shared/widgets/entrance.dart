import 'package:flutter/material.dart';

import '../../style/app_size.dart';
import '../../style/app_tokens.dart';

/// Content entering: rises and fades in once, on the spec's curve.
///
/// Used only for empty and error states — never on a screen push, where a
/// staff member at a barrier would be waiting on it. Under reduced motion it
/// renders its final frame immediately.
class Entrance extends StatelessWidget {
  /// Wraps [child] so it rises and fades in when first built.
  const Entrance({required this.child, super.key});

  /// The content that enters.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: AppMotion.reduced(context) ? 1 : 0, end: 1),
      duration: AppMotion.of(context, AppMotion.enter),
      curve: AppMotion.curve,
      child: child,
      builder: (BuildContext context, double t, Widget? child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, AppSize.getHeight(AppMotion.enterOffsetY) * (1 - t)),
          child: child,
        ),
      ),
    );
  }
}

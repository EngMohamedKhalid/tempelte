import 'package:flutter/material.dart';
import '../../../../../core/style/app_colors.dart';
import '../widgets/splash_mark.dart';

/// The splash's logo, shown while the session is resolved.
class SplashBody extends StatelessWidget {
  const SplashBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(child: SplashMark()),
    );
  }
}

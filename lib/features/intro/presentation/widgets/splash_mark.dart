import 'package:flutter/material.dart';

import '../../../../../core/constant/app_assets.dart';
import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/shared/widgets/bay_frame.dart';

/// The splash mark: the logo parked inside a marked bay.
///
/// There is no animation here on purpose. The entry flow has no artificial
/// delay, so this is on screen for a few frames — motion would either go
/// unseen or, worse, have to be waited for.
class SplashMark extends StatelessWidget {
  const SplashMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: AppSize.getWidth(260),
        child: BayFrame(
          // Green reads on the light ground and matches the marks framing the
          // logo on the auth screens.
          color: AppColors.secondary,
          child: Image.asset(
            AppImages.logo,
            fit: BoxFit.contain,
            width: double.infinity,
            height: AppSize.getHeight(110),
            // Decoded at display size rather than source size, so the
            // bitmap held in memory matches what is painted.
            cacheWidth: AppSize.cacheWidth(AppSize.getWidth(204)),
          ),
        ),
      ),
    );
  }
}

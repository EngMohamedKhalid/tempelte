import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/shared/widgets/custom_button.dart';
import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/style/app_tokens.dart';
import '../controller/force_update_cubit.dart';
import '../../../../../core/shared/widgets/bay_frame.dart';
import '../widgets/version_row.dart';

/// Shown when the store has a build the user has to install.
///
/// Deliberately not a dialog over a screen they cannot use: this is the whole
/// screen, it says plainly what is happening, and it offers exactly one thing
/// to do. The bay marks tie it to the rest of the app without adding an
/// ornamental illustration that carries no information.
///
/// Corrections to the legacy `UpdatePopup`: the store URL and bundle id come
/// from configuration rather than being pasted inline, the typeface is the one
/// the app ships (the legacy asks for "Almarai", which is not in the project
/// and silently falls back), and the cubit opens the store so no
/// `BuildContext` has to survive an await.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({
    required this.storeVersion,
    required this.installedVersion,
    super.key,
  });

  final String storeVersion;
  final String installedVersion;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: AppSize.padding(horizontal: AppSpacing.page, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The content scrolls and the action stays put. A Column of
              // Spacers looks fine at 390pt and overflows at 320pt, which is
              // a real phone.
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: AppSize.getHeight(40)),
                      BayFrame(
                padding: 22,
                armLength: 22,
                color: AppColors.secondary,
                        child: Icon(
                          Icons.system_update_rounded,
                          size: AppSize.getSize(40),
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: AppSize.getHeight(32)),
                      Text(
                        'update.available'.tr(),
                        textAlign: TextAlign.start,
                        // design: hero heading — 28/700, no textTheme role at this size
                        style: TextStyle(
                          height: 1.25,
                          fontSize: AppSize.font(28),
                          fontWeight: FontWeight.w700,
                          color: AppColors.typographyHeading,
                        ),
                      ),
                      SizedBox(height: AppSize.getHeight(12)),
                      Text(
                        'update.desc'.tr(),
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          height: 1.6,
                          color: AppColors.typographySubtitle,
                        ),
                      ),
                      SizedBox(height: AppSize.getHeight(24)),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: VersionRow(
                          installed: installedVersion,
                          store: storeVersion,
                        ),
                      ),
                      SizedBox(height: AppSize.getHeight(24)),
                    ],
                  ),
                ),
              ),
              CustomButton(
                title: 'update.update_now'.tr(),
                onTap: () => ForceUpdateCubit.get(context).openStore(),
              ),
              SizedBox(height: AppSize.getHeight(8)),
            ],
          ),
        ),
      ),
    );
  }
}

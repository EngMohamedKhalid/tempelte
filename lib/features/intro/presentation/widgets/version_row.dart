import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../../core/style/app_colors.dart';
import '../../../../../core/style/app_size.dart';
import '../../../../../core/style/app_tokens.dart';

/// Installed version → store version, set like the numbered tag on a key fob.
///
/// Forced left-to-right and monospaced-by-figure so the two numbers line up
/// and read the same way in Arabic as in English. Version strings are not
/// language, and mirroring them makes them wrong.
class VersionRow extends StatelessWidget {
  const VersionRow({
    required this.installed,
    required this.store,
    super.key,
  });

  final String installed;
  final String store;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Container(
        padding: AppSize.padding(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          border: Border.all(color: AppColors.separatingPrimaryBorder),
          // A card-like box, matching the control/card radius used elsewhere
          // rather than the small chip radius (X3 in the F20 review).
          borderRadius: BorderRadius.circular(AppSize.getSize(AppRadius.control)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // A build suffix makes these longer than they look — `5.5.7+11113`
            // is eleven characters, and two of them plus the arrow will not fit
            // a 320pt phone. They shrink rather than overflow.
            Flexible(child: _Version(installed, color: AppColors.grey81)),
            Padding(
              padding: AppSize.padding(horizontal: 12),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: AppSize.getSize(16),
                color: AppColors.secondary,
              ),
            ),
            Flexible(
              child: _Version(store, color: AppColors.typographyHeading),
            ),
          ],
        ),
      ),
    );
  }
}

class _Version extends StatelessWidget {
  const _Version(this.value, {required this.color});

  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleSmall!.copyWith(color: color),
    );
  }
}

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../helper/app_navigator.dart';
import '../../style/app_colors.dart';
import '../../style/app_size.dart';
import '../../style/app_tokens.dart';

/// The app's dialog shell — the legacy name, restyled to the design system.
///
/// With only [children] it renders exactly as before, so un-migrated dialogs
/// keep working. With a [title] it gains a header and a close button; with
/// [actions] it gains the footer strip, actions at the end.
class CustomDialog extends StatelessWidget {
  /// Creates the dialog shell.
  const CustomDialog({
    super.key,
    required this.children,
    this.title,
    this.actions,
  });

  /// The dialog's body content.
  final List<Widget> children;

  /// 18/700 heading with a close button beside it.
  final String? title;

  /// Buttons for the footer strip, in reading order — the last one ends at
  /// the end edge.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final bool dark = AppColors.isDark();
    final List<Widget> footer = actions ?? const <Widget>[];

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        vertical: AppSize.getHeight(20),
        horizontal: AppSize.getWidth(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 512),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (title != null)
              Padding(
                padding: AppSize.padding(start: 24, end: 8, top: 12),
                child: Row(
                  children: <Widget>[
                    // The vertical 8 is inside the close button's 48 on a
                    // one-line title, so those dialogs do not move; a title
                    // that wraps keeps a gap to the body instead of sitting
                    // on it.
                    Expanded(
                      child: Padding(
                        padding: AppSize.padding(vertical: AppSpacing.gapS),
                        child: Text(title!, style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ),
                    IconButton(
                      tooltip: 'core.close'.tr(),
                      onPressed: AppNavigator.pop,
                      icon: Icon(Icons.close_rounded, color: AppColors.typographySubtitle),
                    ),
                  ],
                ),
              ),
            Flexible(
              child: SingleChildScrollView(
                padding: title == null
                    ? AppSize.padding(horizontal: 20, vertical: 32)
                    : AppSize.padding(horizontal: 24, top: 4, bottom: 24),
                child: Column(mainAxisSize: MainAxisSize.min, children: children),
              ),
            ),
            if (footer.isNotEmpty)
              DecoratedBox(
                key: const ValueKey<String>('custom_dialog_footer'),
                decoration: BoxDecoration(
                  color: dark
                      ? AppColors.navy950.withValues(alpha: 0.6)
                      : AppColors.navy50.withValues(alpha: 0.6),
                  border: Border(
                    top: BorderSide(color: AppColors.separatingPrimaryBorder),
                  ),
                ),
                child: Padding(
                  padding: AppSize.padding(horizontal: 24, vertical: 16),
                  child: Row(
                    children: <Widget>[
                      for (int i = 0; i < footer.length; i++) ...<Widget>[
                        if (i > 0) SizedBox(width: AppSize.getWidth(12)),
                        Expanded(child: footer[i]),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
